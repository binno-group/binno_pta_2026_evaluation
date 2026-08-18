// Package arch_test enforces module and layering boundaries.
package arch_test

import (
	"go/ast"
	"go/token"
	"os"
	"strings"
	"testing"

	"golang.org/x/tools/go/packages"
)

const (
	modPrefix      = "github.com/binnoapp-glitch/binno_backend/internal/modules/"
	platformPrefix = "github.com/binnoapp-glitch/binno_backend/internal/platform/"
	analyticsPkg   = "github.com/binnoapp-glitch/binno_backend/internal/platform/database/analytics"
	dispatcherPkg  = "github.com/binnoapp-glitch/binno_backend/cmd/dispatcher"
)

func load(t *testing.T, mode packages.LoadMode, patterns ...string) []*packages.Package {
	t.Helper()
	cfg := &packages.Config{Mode: mode | packages.NeedName | packages.NeedImports | packages.NeedFiles}
	pkgs, err := packages.Load(cfg, patterns...)
	if err != nil {
		t.Fatalf("load: %v", err)
	}
	if packages.PrintErrors(pkgs) > 0 {
		t.Fatal("packages contain build errors")
	}
	return pkgs
}

func moduleOf(pkgPath string) (name, sub string, ok bool) {
	rest, found := strings.CutPrefix(pkgPath, modPrefix)
	if !found {
		return "", "", false
	}
	parts := strings.SplitN(rest, "/", 2)
	name = parts[0]
	if len(parts) == 2 {
		sub = parts[1]
	}
	return name, sub, true
}

// R1: cross-module imports only via the module root (module.go surface) or its
// events package.
func TestCrossModuleBoundaries(t *testing.T) {
	pkgs := load(t, 0, "github.com/binnoapp-glitch/binno_backend/internal/modules/...")
	if len(pkgs) == 0 {
		t.Skip("no modules implemented yet")
	}
	for _, p := range pkgs {
		fromMod, _, _ := moduleOf(p.PkgPath)
		for imp := range p.Imports {
			toMod, toSub, isMod := moduleOf(imp)
			if !isMod || toMod == fromMod {
				continue
			}
			if toSub == "" || toSub == "events" {
				continue // allowed surface
			}
			t.Errorf("%s imports %s: module %q may only import %q via its root or events package",
				p.PkgPath, imp, fromMod, toMod)
		}
	}
}

// Generated data access belongs to the module that owns it.
func TestNoParallelGeneratedTree(t *testing.T) {
	if _, err := os.Stat("../../internal/dbsqlc"); !os.IsNotExist(err) {
		t.Error("internal/dbsqlc exists again: generated queries must live in " +
			"internal/modules/<module>/store so cross-module access is visible to R1")
	}
	for _, p := range load(t, 0, "github.com/binnoapp-glitch/binno_backend/internal/modules/...") {
		fromMod, fromSub, _ := moduleOf(p.PkgPath)
		if fromSub != "store" {
			continue
		}
		for imp := range p.Imports {
			if _, _, isMod := moduleOf(imp); isMod {
				t.Errorf("%s/store imports business module %s: generated persistence must stay dependency-free",
					fromMod, imp)
			}
		}
	}
}

// Platform packages do not import business modules.
func TestPlatformPurity(t *testing.T) {
	for _, p := range load(t, 0, "github.com/binnoapp-glitch/binno_backend/internal/platform/...") {
		for imp := range p.Imports {
			if strings.HasPrefix(imp, modPrefix) {
				t.Errorf("%s imports business module %s", p.PkgPath, imp)
			}
		}
	}
}

// money is integer tiyin (int64).
func TestNoFloatInModules(t *testing.T) {
	pkgs := load(t, packages.NeedSyntax|packages.NeedTypes, "github.com/binnoapp-glitch/binno_backend/internal/modules/...")
	if len(pkgs) == 0 {
		t.Skip("no modules implemented yet")
	}
	for _, p := range pkgs {
		for _, f := range p.Syntax {
			file := p.Fset.Position(f.Pos()).Filename
			switch {
			case isGenerated(f),
				strings.HasSuffix(file, ".sql.go"),
				strings.HasSuffix(file, "_gen.go"),
				strings.Contains(file, "/geo/"),
				hasComment(f, "arch:allow-float"):
				continue
			}
			ast.Inspect(f, func(n ast.Node) bool {
				switch x := n.(type) {
				case *ast.Ident:
					if x.Name == "float32" || x.Name == "float64" {
						reportFloat(t, p, x.Pos(), x.Name)
					}
				case *ast.BasicLit:
					if x.Kind == token.FLOAT {
						reportFloat(t, p, x.Pos(), x.Value)
					}
				}
				return true
			})
		}
	}
}

func reportFloat(t *testing.T, p *packages.Package, pos token.Pos, what string) {
	t.Helper()
	at := p.Fset.Position(pos)
	t.Errorf("%s:%d: %s in module code; money is int64 tiyin and coordinates live "+
		"in platform/database/geo", at.Filename, at.Line, what)
}

func hasComment(f *ast.File, marker string) bool {
	for _, cg := range f.Comments {
		if strings.Contains(cg.Text(), marker) {
			return true
		}
	}
	return false
}

func isGenerated(f *ast.File) bool {
	for _, cg := range f.Comments {
		for _, c := range cg.List {
			if strings.HasPrefix(c.Text, "// Code generated ") &&
				strings.HasSuffix(c.Text, " DO NOT EDIT.") {
				return true
			}
		}
	}
	return false
}

// allowedSyncCalls is the closed list of synchronous cross-module calls.
var allowedSyncCalls = map[string]bool{
	// catalog.OrderLinePort: ordering needs pricing and stock, which catalog owns.
	"ReserveOrderLines": true,
	"ReleaseOrderLines": true,
	"ConsumeOrderLines": true,
	"ListAlternatives":  true,
	// orders.SummaryPort: billing authorises an invoice by the order's buyer or
	// store, trust accepts feedback only on a closed order.
	"GetOrderSummary": true,
	// location.SaleGatePort: the order path has to know whether a store may sell
	// before it reserves stock, and which owner account the commission belongs to.
	"ResolveSellerForOrder": true,
	// orders.SettlementPort: implemented by billing, declared by orders.
	"IssueInvoice":         true,
	"RecordPaymentReceipt": true,
	"SettlePayment":        true,
	"AccrueCommission":     true,
	"CancelSettlement":     true,
	"OpenRefund":           true,
	"CompleteRefund":       true,
}

func TestSyncCallAllowlist(t *testing.T) {
	pkgs := load(t, packages.NeedSyntax, "github.com/binnoapp-glitch/binno_backend/internal/modules/...")
	if len(pkgs) == 0 {
		t.Skip("no modules implemented yet")
	}
	for _, p := range pkgs {
		_, sub, isMod := moduleOf(p.PkgPath)
		if !isMod || sub != "" {
			continue // module root only; module.go is the public surface
		}
		for _, f := range p.Syntax {
			ast.Inspect(f, func(n ast.Node) bool {
				ts, ok := n.(*ast.TypeSpec)
				if !ok || !ts.Name.IsExported() {
					return true
				}
				it, ok := ts.Type.(*ast.InterfaceType)
				if !ok {
					return true
				}
				for _, m := range it.Methods.List {
					for _, name := range m.Names {
						if !name.IsExported() || allowedSyncCalls[name.Name] {
							continue
						}
						pos := p.Fset.Position(name.Pos())
						t.Errorf("%s:%d: %s.%s is not an allowed synchronous cross-module call",
							pos.Filename, pos.Line, ts.Name.Name, name.Name)
					}
				}
				return true
			})
		}
	}
}

// analytics isolation: only the dispatcher may touch the analytics sink;
// business modules must never import it (no dual-write).
func TestAnalyticsIsolation(t *testing.T) {
	for _, p := range load(t, 0, "github.com/binnoapp-glitch/binno_backend/internal/...", "github.com/binnoapp-glitch/binno_backend/cmd/...") {
		for imp := range p.Imports {
			if !strings.HasPrefix(imp, analyticsPkg) {
				continue
			}
			if !strings.HasPrefix(p.PkgPath, dispatcherPkg) &&
				!strings.HasPrefix(p.PkgPath, analyticsPkg) {
				t.Errorf("%s imports platform/database/analytics; only cmd/dispatcher may", p.PkgPath)
			}
		}
	}
}
