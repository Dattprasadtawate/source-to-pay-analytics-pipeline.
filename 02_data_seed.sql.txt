-- ====================================================================
-- Project: Source-to-Pay (S2P) Analytics Pipeline
-- Domain: Indian FMCG / Sports Nutrition Manufacturing
-- Description: Clean transactional seed data for schema validation & Power BI
-- ====================================================================

-- 1. Wipe existing records cleanly in foreign key dependency order
DELETE FROM invoices;
DELETE FROM goods_receipts;
DELETE FROM purchase_orders;
DELETE FROM suppliers;

-- 2. Insert 10 Indian Nutrition & Packaging Suppliers
INSERT INTO suppliers (vendor_id, vendor_name, category, payment_terms, country)
SELECT 
    'VEN-I' || LPAD(i::text, 3, '0'),
    (ARRAY[
        'MahaDairy Ingredients Pvt Ltd',
        'Gujarat Agro & Whey Extracts',
        'Baddi Pharma Packaging Solutions',
        'South India Flavors & Aromas',
        'Haryana Polymers & Containers',
        'Baramati Agro Derivatives Ltd',
        'Sylvan Nutrition Raw Mills',
        'Deccan Stevia & Sweeteners',
        'Surat Rigid Plastics & Caps',
        'Uttarakhand Herbal Extracts'
    ])[i],
    (ARRAY[
        'Dairy Raw Materials',
        'Dairy Raw Materials',
        'Primary Packaging',
        'Flavors & Aromas',
        'Secondary Packaging',
        'Dairy Derivatives',
        'Agri Raw Materials',
        'Sweeteners',
        'Packaging Caps',
        'Herbal Extracts'
    ])[i],
    (ARRAY['Net 30', 'Net 45', 'Net 15', 'Net 30', 'Net 60', 'Net 30', 'Net 45', 'Net 15', 'Net 30', 'Net 60'])[i],
    'IN'
FROM generate_series(1, 10) AS i;

-- 3. Insert 150 Purchase Orders for Whey Nutrition Ingredients & Materials
INSERT INTO purchase_orders (po_id, vendor_id, po_date, promised_date, ordered_qty, unit_price, total_po_value)
SELECT 
    'PO-I' || LPAD(i::text, 4, '0'),
    'VEN-I' || LPAD((1 + floor(random() * 10))::int::text, 3, '0'),
    DATE '2026-01-01' + (i % 65) * INTERVAL '1 day',
    DATE '2026-01-01' + ((i % 65) + 10) * INTERVAL '1 day',
    qty,
    price,
    ROUND((qty * price)::numeric, 2)
FROM (
    SELECT 
        i,
        (100 + floor(random() * 900))::int AS qty,
        ROUND((150 + (random() * 1850))::numeric, 2) AS price
    FROM generate_series(1, 150) AS i
) sub;

-- 4. Insert Goods Receipts (Warehouse Intake with QC Scraps & Transit Variances)
INSERT INTO goods_receipts (gr_id, po_id, delivery_date, received_qty, defect_qty, accepted_qty)
SELECT 
    'GR-I' || LPAD(ROW_NUMBER() OVER ()::text, 4, '0'),
    sub.po_id,
    sub.promised_date + (floor(random() * 7) - 2) * INTERVAL '1 day',
    sub.r_qty,
    sub.d_qty,
    (sub.r_qty - sub.d_qty) AS accepted_qty
FROM (
    SELECT 
        po_id,
        promised_date,
        CASE 
            WHEN random() < 0.12 THEN ordered_qty - 40
            ELSE ordered_qty 
        END AS r_qty,
        CASE 
            WHEN random() < 0.10 THEN floor(random() * 15)::int
            ELSE 0 
        END AS d_qty
    FROM purchase_orders
    WHERE random() > 0.05
) sub;

-- 5. Insert Invoices (Simulating 3-Way Matching Variances & Status Constraints)
INSERT INTO invoices (inv_id, po_id, inv_date, due_date, billed_qty, billed_unit_price, inv_amount, payment_status)
SELECT 
    'INV-I' || LPAD(ROW_NUMBER() OVER ()::text, 4, '0'),
    sub.po_id,
    sub.delivery_date + INTERVAL '2 days',
    sub.delivery_date + INTERVAL '32 days',
    sub.final_billed_qty,
    sub.final_billed_price,
    ROUND((sub.final_billed_qty * sub.final_billed_price)::numeric, 2),
    sub.status
FROM (
    SELECT 
        gr.po_id,
        gr.delivery_date,
        CASE 
            WHEN random() < 0.12 THEN po.ordered_qty + 15
            ELSE gr.received_qty
        END AS final_billed_qty,
        CASE 
            WHEN random() < 0.09 THEN po.unit_price + 45.00
            ELSE po.unit_price 
        END AS final_billed_price,
        CASE 
            WHEN random() < 0.45 THEN 'Paid'
            WHEN random() < 0.80 THEN 'Pending'
            ELSE 'Blocked'
        END AS status
    FROM goods_receipts gr
    JOIN purchase_orders po ON gr.po_id = po.po_id
) sub;

-- 6. Verification Summary Audit
SELECT 
    (SELECT COUNT(*) FROM suppliers) AS total_vendors,
    (SELECT COUNT(*) FROM purchase_orders) AS total_pos,
    (SELECT COUNT(*) FROM goods_receipts) AS total_receipts,
    (SELECT COUNT(*) FROM invoices) AS total_invoices;