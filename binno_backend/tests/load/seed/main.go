// Command seed prepares a disposable environment for the k6 capacity profiles:
// marketplace rows sized for sustained load, and pre-minted JWTs so the load
// generator never touches the OTP/SMS flow. Point it only at load
// environments — it writes bearer tokens to disk.
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"math/rand/v2"
	"os"
	"path/filepath"
	"time"

	"github.com/google/uuid"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/authz"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
)

// loadDistrictID is a fixed out-of-band district so repeated seeds reuse it.
const loadDistrictID = 999901

type env struct {
	StoreID     string   `json:"store_id"`
	ComplexID   string   `json:"complex_id"`
	DistrictID  int32    `json:"district_id"`
	Lat         float64  `json:"lat"`
	Lng         float64  `json:"lng"`
	ProductIDs  []string `json:"product_ids"`
	SellerToken string   `json:"seller_token"`
	BuyerTokens []string `json:"buyer_tokens"`
}

func main() {
	dbURL := flag.String("db", os.Getenv("DB_URL"), "PostgreSQL DSN of the load environment")
	signingKey := flag.String("signing-key", os.Getenv("JWT_SIGNING_KEY"), "the server's JWT_SIGNING_KEY")
	buyers := flag.Int("buyers", 50, "buyer accounts to mint tokens for")
	products := flag.Int("products", 20, "products with one offer each")
	tokenTTL := flag.Duration("token-ttl", 24*time.Hour, "minted token lifetime")
	out := flag.String("out", "tests/load/out/env.json", "where to write the k6 environment")
	flag.Parse()

	if *dbURL == "" || *signingKey == "" {
		log.Fatal("both -db (or DB_URL) and -signing-key (or JWT_SIGNING_KEY) are required")
	}

	ctx := context.Background()
	pool, err := postgres.NewPool(ctx, postgres.Config{
		URL: *dbURL, MaxConns: 4, StatementTimeout: time.Minute,
	})
	if err != nil {
		log.Fatalf("connect: %v", err)
	}
	defer pool.Close()

	signer, err := httpx.NewSigner(*signingKey, *tokenTTL)
	if err != nil {
		log.Fatalf("signer: %v", err)
	}

	result, err := seedWorld(ctx, pool, signer, *buyers, *products)
	if err != nil {
		log.Fatalf("seed: %v", err)
	}

	if err := os.MkdirAll(filepath.Dir(*out), 0o755); err != nil {
		log.Fatalf("create output dir: %v", err)
	}
	raw, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		log.Fatalf("encode env: %v", err)
	}
	if err := os.WriteFile(*out, raw, 0o600); err != nil {
		log.Fatalf("write env: %v", err)
	}
	fmt.Printf("seeded store %s with %d products and %d buyers -> %s\n",
		result.StoreID, len(result.ProductIDs), len(result.BuyerTokens), *out)
}

func seedWorld(ctx context.Context, pool *postgres.Pool, signer *httpx.Signer, buyers, products int) (env, error) {
	const lat, lng = 41.311, 69.24
	now := time.Now().UTC()

	exec := func(sql string, args ...any) error {
		_, err := pool.Exec(ctx, sql, args...)
		return err
	}
	phone := func() string {
		digits := make([]byte, 9)
		for i := range digits {
			digits[i] = byte('0' + rand.IntN(10))
		}
		return "998" + string(digits)
	}

	if err := exec(`INSERT INTO location.districts (id, name, region_id)
	                VALUES ($1, 'Load District', 1) ON CONFLICT (id) DO NOTHING`,
		loadDistrictID); err != nil {
		return env{}, fmt.Errorf("district: %w", err)
	}

	complexID := uuid.NewString()
	if err := exec(`INSERT INTO location.trade_complexes (id, name, district_id, location)
	                VALUES ($1, 'Load Complex', $2,
	                        ST_SetSRID(ST_MakePoint($3, $4), 4326)::geography)`,
		complexID, loadDistrictID, lng, lat); err != nil {
		return env{}, fmt.Errorf("complex: %w", err)
	}

	sellerUserID := uuid.NewString()
	ownerID := uuid.NewString()
	storeID := uuid.NewString()
	if err := exec(`INSERT INTO identity.users (id, phone, status, created_at)
	                VALUES ($1, $2, 'active', now())`, sellerUserID, phone()); err != nil {
		return env{}, fmt.Errorf("seller user: %w", err)
	}
	tin := fmt.Sprintf("%09d", rand.IntN(1_000_000_000))
	if err := exec(`INSERT INTO location.owners
	                  (id, user_id, tin, legal_name, status, is_founding, credit_limit, created_at)
	                VALUES ($1, $2, $3, 'Load Test LLC', 'active', false, 0, now())`,
		ownerID, sellerUserID, tin); err != nil {
		return env{}, fmt.Errorf("owner: %w", err)
	}
	if err := exec(`INSERT INTO location.stores
	                  (id, owner_id, name, complex_id, status, location, created_at)
	                VALUES ($1, $2, 'Load Test Store', $3, 'active',
	                        ST_SetSRID(ST_MakePoint($4, $5), 4326)::geography, now())`,
		storeID, ownerID, complexID, lng, lat); err != nil {
		return env{}, fmt.Errorf("store: %w", err)
	}
	if err := exec(`INSERT INTO catalog.delivery_tariffs (store_id, district_id, price, updated_at)
	                VALUES ($1, $2, 15000, now()) ON CONFLICT DO NOTHING`,
		storeID, loadDistrictID); err != nil {
		return env{}, fmt.Errorf("tariff: %w", err)
	}

	categoryID := uuid.NewString()
	if err := exec(`INSERT INTO catalog.categories (id, name, confirm_window_minutes, commission_bps)
	                VALUES ($1, 'Load Category', 240, 250)`, categoryID); err != nil {
		return env{}, fmt.Errorf("category: %w", err)
	}

	productIDs := make([]string, 0, products)
	for i := range products {
		productID := uuid.NewString()
		if err := exec(`INSERT INTO catalog.products (id, category_id, name, unit, created_at)
		                VALUES ($1, $2, $3, 'bag', now())`,
			productID, categoryID, fmt.Sprintf("Load Product %02d", i)); err != nil {
			return env{}, fmt.Errorf("product %d: %w", i, err)
		}
		// Declared stock far above what any profile can consume, so capacity
		// runs measure the service, not stock exhaustion.
		if err := exec(`INSERT INTO catalog.offers
		                  (id, store_id, product_id, price, declared_qty, reserved_qty, freshness_at, status)
		                VALUES ($1, $2, $3, $4, 1000000000, 0, now(), 'published')`,
			uuid.NewString(), storeID, productID, int64(5_000+rand.IntN(50_000))); err != nil {
			return env{}, fmt.Errorf("offer %d: %w", i, err)
		}
		productIDs = append(productIDs, productID)
	}

	sellerToken, err := signer.Sign(sellerUserID, []authz.Role{authz.RoleSeller}, now)
	if err != nil {
		return env{}, fmt.Errorf("seller token: %w", err)
	}
	buyerTokens := make([]string, 0, buyers)
	for range buyers {
		buyerUserID := uuid.NewString()
		if err := exec(`INSERT INTO identity.users (id, phone, status, created_at)
		                VALUES ($1, $2, 'active', now())`, buyerUserID, phone()); err != nil {
			return env{}, fmt.Errorf("buyer user: %w", err)
		}
		token, err := signer.Sign(buyerUserID, []authz.Role{authz.RoleBuyer}, now)
		if err != nil {
			return env{}, fmt.Errorf("buyer token: %w", err)
		}
		buyerTokens = append(buyerTokens, token)
	}

	return env{
		StoreID: storeID, ComplexID: complexID, DistrictID: loadDistrictID,
		Lat: lat, Lng: lng, ProductIDs: productIDs,
		SellerToken: sellerToken, BuyerTokens: buyerTokens,
	}, nil
}
