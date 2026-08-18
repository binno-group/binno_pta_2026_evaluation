package catalog

import (
	"context"
	"errors"
	"strings"
	"testing"
)

func validCatalogRequest() CatalogRequestInput {
	return CatalogRequestInput{
		StoreID:     ownedStore,
		Name:        "Qishloq guruchi",
		Unit:        "kg",
		Description: "long grain rice",
	}
}

func TestCreateCatalogRequestOnOwnedStore(t *testing.T) {
	repo := &fakeRepository{}
	id, err := newService(repo, ownedStore).CreateCatalogRequest(context.Background(), validCatalogRequest())
	if err != nil {
		t.Fatalf("CreateCatalogRequest error = %v", err)
	}
	if id != requestOne {
		t.Errorf("id = %q, want %q", id, requestOne)
	}
	if repo.requests != 1 {
		t.Errorf("repository writes = %d, want 1", repo.requests)
	}
}

func TestCreateCatalogRequestRejectsForeignStore(t *testing.T) {
	repo := &fakeRepository{}
	// Caller owns nothing, so the guard denies the store.
	_, err := newService(repo).CreateCatalogRequest(context.Background(), validCatalogRequest())
	if err == nil {
		t.Fatal("CreateCatalogRequest allowed a request against an unowned store")
	}
	if repo.requests != 0 {
		t.Errorf("repository writes = %d, want 0", repo.requests)
	}
}

func TestCreateCatalogRequestValidatesInput(t *testing.T) {
	base := validCatalogRequest()
	cases := map[string]func(*CatalogRequestInput){
		"bad store id":  func(in *CatalogRequestInput) { in.StoreID = "not-a-uuid" },
		"empty name":    func(in *CatalogRequestInput) { in.Name = "   " },
		"name too long": func(in *CatalogRequestInput) { in.Name = strings.Repeat("a", 201) },
		"empty unit":    func(in *CatalogRequestInput) { in.Unit = "" },
		"unit too long": func(in *CatalogRequestInput) { in.Unit = strings.Repeat("u", 31) },
		"desc too long": func(in *CatalogRequestInput) { in.Description = strings.Repeat("d", 2001) },
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			repo := &fakeRepository{}
			in := base
			mutate(&in)
			if _, err := newService(repo, ownedStore).CreateCatalogRequest(context.Background(), in); !errors.Is(err, ErrInvalid) {
				t.Fatalf("error = %v, want ErrInvalid", err)
			}
			if repo.requests != 0 {
				t.Errorf("invalid input still reached the repository (%d writes)", repo.requests)
			}
		})
	}
}
