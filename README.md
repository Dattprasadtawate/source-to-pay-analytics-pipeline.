# Source-to-Pay (S2P) Analytics Pipeline

An end-to-end data analytics pipeline modeling the enterprise procurement lifecycle: purchase requisitions, purchase orders, goods receipts, invoice matching, and vendor payment settlement.

## Project Structure
- `01_schema.sql` — Relational schema definitions (DDL) with foreign keys and constraints.
- `02_data_seed.sql` — Synthetic dataset simulating realistic procurement operations.
- `03_analytics_queries.sql` — Core business intelligence queries (spend analysis, PO-to-invoice match discrepancies, and payment cycle time metrics).

## Tech Stack
- **Database Engine:** PostgreSQL
- **Modeling:** Relational Star / Normalized Schema
- **Analysis:** SQL Window Functions, CTEs, Aggregations
