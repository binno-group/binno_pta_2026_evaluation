package config

import "testing"

// The default must scale with the pool, not sit at a constant.
func TestAdmissionLimitDerivesFromPool(t *testing.T) {
	t.Parallel()
	for _, tc := range []struct {
		name    string
		conns   int32
		perConn int
		want    int
	}{
		{"default pool", 20, 4, 80},
		{"larger pool scales the limit", 50, 4, 200},
		{"per-conn factor is honoured", 20, 8, 160},
	} {
		t.Run(tc.name, func(t *testing.T) {
			c := Config{OLTPMaxConns: tc.conns, HTTPInFlightPerConn: tc.perConn}
			if err := c.resolveAdmissionLimit(); err != nil {
				t.Fatalf("resolveAdmissionLimit: %v", err)
			}
			if c.HTTPMaxInFlight != tc.want {
				t.Errorf("HTTPMaxInFlight = %d, want %d", c.HTTPMaxInFlight, tc.want)
			}
		})
	}
}

func TestExplicitAdmissionLimitIsHonoured(t *testing.T) {
	t.Parallel()
	c := Config{OLTPMaxConns: 20, HTTPInFlightPerConn: 4, HTTPMaxInFlight: 100}
	if err := c.resolveAdmissionLimit(); err != nil {
		t.Fatalf("resolveAdmissionLimit: %v", err)
	}
	if c.HTTPMaxInFlight != 100 {
		t.Errorf("explicit value overwritten: got %d, want 100", c.HTTPMaxInFlight)
	}
}

// The old default was 512 against a 20-connection pool, or 25x.
func TestAbsurdRatioIsRefusedAtBoot(t *testing.T) {
	t.Parallel()
	c := Config{OLTPMaxConns: 20, HTTPInFlightPerConn: 4, HTTPMaxInFlight: 512}
	err := c.resolveAdmissionLimit()
	if err == nil {
		t.Fatal("512 in flight against 20 connections was accepted; this is the ratio that collapsed")
	}
	for _, want := range []string{"HTTP_MAX_IN_FLIGHT", "OLTP_MAX_CONNS", "cancelled"} {
		if !contains(err.Error(), want) {
			t.Errorf("error does not mention %q, so an operator cannot act on it: %v", want, err)
		}
	}
}

// Disabling must stay possible and must be an explicit act: a negative value,
// not zero.
func TestNegativeDisablesAdmissionControl(t *testing.T) {
	t.Parallel()
	c := Config{OLTPMaxConns: 20, HTTPInFlightPerConn: 4, HTTPMaxInFlight: -1}
	if !c.AdmissionDisabled() {
		t.Error("negative HTTP_MAX_IN_FLIGHT should report as disabled")
	}
	if err := c.resolveAdmissionLimit(); err != nil {
		t.Fatalf("resolveAdmissionLimit: %v", err)
	}
	if c.HTTPMaxInFlight != 0 {
		t.Errorf("disabled should normalise to 0 for LimitInFlight, got %d", c.HTTPMaxInFlight)
	}
}

func contains(haystack, needle string) bool {
	return len(haystack) >= len(needle) && func() bool {
		for i := 0; i+len(needle) <= len(haystack); i++ {
			if haystack[i:i+len(needle)] == needle {
				return true
			}
		}
		return false
	}()
}
