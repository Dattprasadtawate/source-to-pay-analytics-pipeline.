DROP TABLE IF EXISTS procurement_audit_log CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS goods_receipts CASCADE;
DROP TABLE IF EXISTS po_line_items CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;

CREATE TABLE vendors (
    vendor_id VARCHAR(10) PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    payment_terms_days INT NOT NULL,
    country VARCHAR(10) NOT NULL,
    risk_tier VARCHAR(10) CHECK (risk_tier IN ('Low', 'Medium', 'High'))
);

CREATE TABLE purchase_orders (
    po_id VARCHAR(15) PRIMARY KEY,
    vendor_id VARCHAR(10) REFERENCES vendors(vendor_id),
    department VARCHAR(50) NOT NULL,
    buyer_id VARCHAR(10) NOT NULL,
    order_date DATE NOT NULL,
    po_status VARCHAR(20) CHECK (po_status IN ('Approved', 'Delivered', 'Invoiced', 'Closed', 'Cancelled'))
);

CREATE TABLE po_line_items (
    po_line_id VARCHAR(20) PRIMARY KEY,
    po_id VARCHAR(15) REFERENCES purchase_orders(po_id),
    item_description VARCHAR(150) NOT NULL,
    quantity_ordered NUMERIC(10, 2) NOT NULL,
    unit_price_ordered NUMERIC(12, 2) NOT NULL,
    line_total_ordered NUMERIC(14, 2) GENERATED ALWAYS AS (quantity_ordered * unit_price_ordered) STORED
);

CREATE TABLE goods_receipts (
    gr_id VARCHAR(15) PRIMARY KEY,
    po_line_id VARCHAR(20) REFERENCES po_line_items(po_line_id),
    receipt_date DATE NOT NULL,
    quantity_received NUMERIC(10, 2) NOT NULL,
    quality_status VARCHAR(20) CHECK (quality_status IN ('Accepted', 'Rejected', 'Partial'))
);

CREATE TABLE invoices (
    invoice_id VARCHAR(15) PRIMARY KEY,
    po_id VARCHAR(15) REFERENCES purchase_orders(po_id),
    vendor_id VARCHAR(10) REFERENCES vendors(vendor_id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    quantity_invoiced NUMERIC(10, 2) NOT NULL,
    unit_price_invoiced NUMERIC(12, 2) NOT NULL,
    invoice_amount NUMERIC(14, 2) NOT NULL,
    match_status VARCHAR(25) CHECK (match_status IN ('3-Way Matched', 'Price Discrepancy', 'Quantity Discrepancy', 'Blocked'))
);

CREATE TABLE payments (
    payment_id VARCHAR(15) PRIMARY KEY,
    invoice_id VARCHAR(15) REFERENCES invoices(invoice_id),
    payment_date DATE NOT NULL,
    amount_paid NUMERIC(14, 2) NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('SEPA', 'Wire', 'ACH', 'Corporate Card')),
    payment_status VARCHAR(20) CHECK (payment_status IN ('Paid On-Time', 'Paid Late', 'Discount Captured'))
);

CREATE TABLE procurement_audit_log (
    audit_id SERIAL PRIMARY KEY,
    entity_name VARCHAR(50),
    entity_key VARCHAR(20),
    action_type VARCHAR(20),
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    flagged_by VARCHAR(50)
);
