SHELL := /bin/bash

.PHONY: help up down logs test-integration \
	migrate-up migrate-down migrate-cycle migrate-create \
	migrate-analytics-up migrate-analytics-down migrate-analytics-cycle migrate-analytics-create \
	sqlc sqlc-check lint fmt vet test arch gates run dispatcher scale \
	grant-operator revoke-operator activate-owner create-store outbox-requeue

DB_URL ?= postgres://binno:binno@localhost:5432/binno?sslmode=disable
ANALYTICS_DB_URL ?= postgres://binno:binno@localhost:5433/binno_analytics?sslmode=disable

OLTP_MIGRATION_DIRS := \
	migrations/platform \
	migrations/identity \
	migrations/location \
	migrations/catalog \
	migrations/orders \
	migrations/billing \
	migrations/trust
REVERSE = $(shell echo $(1) | tr ' ' '\n' | sed '1!G;h;$$!d')

help:
	@echo "up | down | logs | scale n=N | lint | test | arch | gates | run | dispatcher"
	@echo "migrate-up | migrate-down | migrate-cycle | migrate-create name=... (OLTP)"
	@echo "migrate-analytics-up | migrate-analytics-down | migrate-analytics-cycle | migrate-analytics-create name=..."
	@echo "sqlc | sqlc-check | fmt | vet"

up:
	docker compose up -d --build

scale:
	docker compose up -d --build --scale binno=$(n) binno
	docker compose restart nginx
	@echo "binno replicas: $(n) (via http://localhost:8080)"

down:
	docker compose down -v

logs:
	docker compose logs -f --tail=200

migrate-up:
	@for d in $(OLTP_MIGRATION_DIRS); do \
	  module=$$(basename $$d); \
	  echo "up: $$d"; \
	  migrate -path $$d -database "$(DB_URL)&x-migrations-table=schema_migrations_$${module}" up || exit 1; \
	done

migrate-down:
	@for d in $(call REVERSE,$(OLTP_MIGRATION_DIRS)); do \
	  module=$$(basename $$d); \
	  echo "down: $$d"; \
	  migrate -path $$d -database "$(DB_URL)&x-migrations-table=schema_migrations_$${module}" down -all || exit 1; \
	done

migrate-cycle:
	$(MAKE) migrate-up DB_URL="$(DB_URL)"
	$(MAKE) migrate-down DB_URL="$(DB_URL)"
	$(MAKE) migrate-up DB_URL="$(DB_URL)"

migrate-create:
	@test -n "$(name)" || (echo "name is required" && exit 1)
	@test -n "$(module)" || (echo "module is required, e.g. module=orders" && exit 1)
	@mkdir -p migrations/$(module)
	migrate create -ext sql -dir migrations/$(module) -seq $(name)

migrate-analytics-up:
	migrate -path migrations/analytics -database "$(ANALYTICS_DB_URL)" up

migrate-analytics-down:
	migrate -path migrations/analytics -database "$(ANALYTICS_DB_URL)" down -all

migrate-analytics-cycle:
	$(MAKE) migrate-analytics-up ANALYTICS_DB_URL="$(ANALYTICS_DB_URL)"
	$(MAKE) migrate-analytics-down ANALYTICS_DB_URL="$(ANALYTICS_DB_URL)"
	$(MAKE) migrate-analytics-up ANALYTICS_DB_URL="$(ANALYTICS_DB_URL)"

migrate-analytics-create:
	@test -n "$(name)" || (echo "name is required" && exit 1)
	migrate create -ext sql -dir migrations/analytics -seq $(name)

sqlc:
	sqlc generate

sqlc-check:
	scripts/sqlc-drift.sh

fmt:
	gofumpt -l -w $$(find . -name '*.go' -not -path './vendor/*')

vet:
	go vet ./...
	go vet -tags=routedump ./scripts/routedump/

lint:
	golangci-lint run --timeout=5m

test:
	go test -race ./...

TEST_ENV_VARS := TEST_DB_URL TEST_ANALYTICS_DB_URL TEST_REDIS_ADDR TEST_CLICKHOUSE_URL

test-integration:
	@for v in $(TEST_ENV_VARS); do \
	  eval "cur=\$$$$v"; \
	  if [ -z "$$cur" ] && [ -f .env ]; then \
	    line=$$(grep -m1 -E "^$$v=" .env || true); \
	    [ -n "$$line" ] && export "$$v=$${line#*=}"; \
	  fi; \
	done; \
	missing=""; for v in $(TEST_ENV_VARS); do \
	  eval "cur=\$$$$v"; [ -n "$$cur" ] || missing="$$missing $$v"; \
	done; \
	if [ -n "$$missing" ]; then \
	  echo "test-integration needs:$$missing" >&2; \
	  echo "Set them in .env (see .env.example) or in the environment. Without them" >&2; \
	  echo "the tests that need a database, Redis or ClickHouse skip themselves and" >&2; \
	  echo "this target reports a pass it did not earn." >&2; \
	  exit 1; \
	fi; \
	docker compose ps --status=running --format '{{.Service}}' 2>/dev/null | grep -qx dispatcher \
	  && { echo "stopping dispatcher: it claims outbox rows the tests need"; \
	       docker compose stop dispatcher >/dev/null; STOPPED=1; } || STOPPED=0; \
	docker compose ps --status=running --format '{{.Service}}' 2>/dev/null | grep -qx clickhouse \
	  && CH_STARTED=0 \
	  || { echo "starting clickhouse: TEST_CLICKHOUSE_URL is set and it lives behind a profile"; \
	       docker compose --profile clickhouse up -d --wait clickhouse >/dev/null 2>&1; CH_STARTED=1; }; \
	log=$$(mktemp); \
	go test -tags=integration -count=1 -v ./... >"$$log" 2>&1; rc=$$?; \
	grep -E '^(ok|FAIL|---)' "$$log" | grep -vE '^--- PASS' || true; \
	[ "$$STOPPED" = "1" ] && docker compose start dispatcher >/dev/null || true; \
	[ "$$CH_STARTED" = "1" ] && docker compose stop clickhouse >/dev/null 2>&1 || true; \
	skipped=$$(grep -c -- '--- SKIP' "$$log" || true); \
	rm -f "$$log"; \
	if [ "$$skipped" -gt 0 ]; then \
	  echo "" >&2; \
	  echo "$$skipped test(s) skipped even though every TEST_* variable is set, so a" >&2; \
	  echo "dependency is unreachable and this run proves less than it appears to." >&2; \
	  echo "Start the stack with 'make up' and retry." >&2; \
	  exit 1; \
	fi; \
	exit $$rc

arch:
	go test ./tests/arch/... -count=1

# Capacity profiles (Layer 4). Never part of test/test-integration: they need
# a dedicated load environment and a seeded tests/load/out/env.json
# (go run ./tests/load/seed). See tests/load/README.md.
load-baseline load-burst load-endurance: load-%:
	tests/load/run.sh $*

gates:
	scripts/todo-gate.sh
	scripts/migration-pairs.sh
	scripts/no-latest.sh
	scripts/mutating-routes.sh
	scripts/sqlc-drift.sh
	scripts/status-write.sh
	scripts/table-ownership.sh
	scripts/alerts-presence.sh

run:
	go run ./cmd/binno

dispatcher:
	go run ./cmd/dispatcher

# Operator capability is granted out-of-band, never through the API.
# Usage: make grant-operator phone=998901234567
grant-operator:
	@test -n "$(phone)" || { echo "usage: make grant-operator phone=998XXXXXXXXX"; exit 1; }
	@psql "$(DB_URL)" -c "UPDATE identity.users SET is_operator = TRUE WHERE phone = '$(phone)';" \
	  | grep -q "UPDATE 1" && echo "operator granted to $(phone)" \
	  || { echo "no user with phone $(phone); they must log in once first"; exit 1; }

revoke-operator:
	@test -n "$(phone)" || { echo "usage: make revoke-operator phone=998XXXXXXXXX"; exit 1; }
	@psql "$(DB_URL)" -c "UPDATE identity.users SET is_operator = FALSE WHERE phone = '$(phone)';"

# Owner activation is an ops decision, never an API call: registration creates
# the account as 'pending' and this is the only path to 'active'.
# Usage: make activate-owner tin=123456789
activate-owner:
	@test -n "$(tin)" || { echo "usage: make activate-owner tin=XXXXXXXXX"; exit 1; }
	@psql "$(DB_URL)" -c "UPDATE location.owners SET status = 'active', verified_at = now() \
	  WHERE tin = '$(tin)' AND status = 'pending';" \
	  | grep -q "UPDATE 1" && echo "owner $(tin) activated" \
	  || { echo "no pending owner with TIN $(tin)"; exit 1; }

# Store creation is ops-only for the MVP; there is deliberately no API for it.
# Usage: make create-store tin=123456789 name="Main Store" lat=41.31 lng=69.24 [phone=998...]
create-store:
	@test -n "$(tin)" && test -n "$(name)" && test -n "$(lat)" && test -n "$(lng)" || \
	  { echo "usage: make create-store tin=XXXXXXXXX name=... lat=... lng=... [phone=...]"; exit 1; }
	@psql "$(DB_URL)" -c "INSERT INTO location.stores (id, owner_id, name, location, phone, status, created_at) \
	  SELECT gen_random_uuid(), o.id, '$(name)', \
	         ST_SetSRID(ST_MakePoint($(lng), $(lat)), 4326)::geography, \
	         NULLIF('$(phone)', ''), 'active', now() \
	  FROM location.owners o WHERE o.tin = '$(tin)' AND o.status = 'active' \
	  RETURNING id;" \
	  | grep -q "INSERT 0 1" && echo "store created for owner $(tin)" \
	  || { echo "no active owner with TIN $(tin); activate-owner first"; exit 1; }

# Returns dead-lettered outbox events to the retry queue after the sink-side
# cause is fixed. Attempt counters reset so the full retry budget applies.
outbox-requeue:
	@psql "$(DB_URL)" -c "UPDATE platform.outbox \
	  SET dead_lettered_at = NULL, attempt_count = 0, next_attempt_at = NULL, \
	      claimed_at = NULL, last_error = NULL \
	  WHERE dead_lettered_at IS NOT NULL;"
