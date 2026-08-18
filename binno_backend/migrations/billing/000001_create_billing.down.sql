DROP TABLE IF EXISTS billing.commission_ledger;
DROP TABLE IF EXISTS billing.commission_invoices;
DROP TABLE IF EXISTS billing.refunds;
DROP TABLE IF EXISTS billing.payments;
DROP TABLE IF EXISTS billing.invoices;
-- DROP SCHEMA without CASCADE refuses a non-empty schema, and the sequence is
-- not owned by any table, so dropping the tables does not take it.
DROP SEQUENCE IF EXISTS billing.invoice_number_seq;
DROP SCHEMA IF EXISTS billing;
