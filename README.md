# Source-to-Pay (S2P) Data Pipeline & Spend Analytics

An end-to-end relational data model and analytical controlling suite simulating enterprise Source-to-Pay procurement operations.

## Architecture & Data Flow
The pipeline models the complete procurement lifecycle across **150 relational operational records**:
1. **Requisition & PO Issuance:** Contracted vendors, terms, and multi-department purchase orders.
2. **Goods Receipt & Inspection:** Warehouse receipt tracking, quality acceptance, and shortfall recording.
3. **3-Way Matching & Discrepancies:** Automated comparison between PO price, GR quantity, and vendor invoice.
4. **Disbursement & Treasury:** Payment term compliance, dynamic cash discounts, and late-fee monitoring.

## Repository Contents
| File | Description | Scope |
|---|---|---|
| `01_schema.sql` | Relational DDL with primary/foreign keys and status constraints | 6 core relational entities |
| `02_data_seed.sql` | Synthetic dataset simulating enterprise procurement | **150 production-style records** |
| `03_analytics_queries.sql` | Business Intelligence & Controlling queries | Spend leakage, 3-Way matching, DPO |

## Key Analytics Use Cases
- **Spend Leakage Detection:** Identifying off-contract price discrepancies and quantity over-invoicing.
- **Three-Way Matching Exception Rate:** Pinpointing vendors with high discrepancy rates.
- **Working Capital & Payment Terms Optimization:** Measuring capture rates of early-payment discounts (Skonto) and Days Payable Outstanding (DPO).

## Technology Stack
- **RDBMS:** PostgreSQL
- **SQL Concepts:** CTEs, Window Functions, Aggregate Analysis, Referential Integrity Constraints
