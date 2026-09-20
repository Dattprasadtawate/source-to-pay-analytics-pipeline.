-- ============================================================================
-- SOURCE-TO-PAY (S2P) ANALYTICS: KPI & CONTROLLING QUERIES
-- ============================================================================

-- KPI 1: Spend Analysis by Procurement Category & Spend Leakage Exposure
SELECT 
    v.category,
    COUNT(DISTINCT po.po_id) AS total_orders,
    SUM(pol.line_total_ordered) AS committed_spend,
    ROUND(AVG(pol.line_total_ordered), 2) AS avg_po_value,
    SUM(CASE WHEN inv.match_status != '3-Way Matched' THEN inv.invoice_amount ELSE 0 END) AS spend_at_risk
FROM vendors v
JOIN purchase_orders po ON v.vendor_id = po.vendor_id
JOIN po_line_items pol ON po.po_id = pol.po_id
LEFT JOIN invoices inv ON po.po_id = inv.po_id
GROUP BY v.category
ORDER BY committed_spend DESC;

-- KPI 2: 3-Way Matching Exception Audit (Quantity vs Unit Price Variances)
SELECT 
    inv.invoice_id,
    po.po_id,
    v.vendor_name,
    pol.quantity_ordered,
    gr.quantity_received,
    inv.quantity_invoiced,
    pol.unit_price_ordered,
    inv.unit_price_invoiced,
    (inv.unit_price_invoiced - pol.unit_price_ordered) * inv.quantity_invoiced AS price_variance_exposure,
    inv.match_status
FROM invoices inv
JOIN purchase_orders po ON inv.po_id = po.po_id
JOIN vendors v ON inv.vendor_id = v.vendor_id
JOIN po_line_items pol ON po.po_id = pol.po_id
LEFT JOIN goods_receipts gr ON pol.po_line_id = gr.po_line_id
WHERE inv.match_status != '3-Way Matched'
ORDER BY price_variance_exposure DESC;

-- KPI 3: Procure-to-Pay Payment Performance & Days Payable Cycle Time
SELECT 
    v.vendor_name,
    v.payment_terms_days AS agreed_terms,
    inv.invoice_id,
    inv.invoice_date,
    p.payment_date,
    (p.payment_date - inv.invoice_date) AS actual_payment_cycle_days,
    CASE 
        WHEN (p.payment_date - inv.invoice_date) <= v.payment_terms_days THEN 'Within Terms'
        ELSE 'Delinquent / Delayed'
    END AS compliance_flag,
    p.payment_status
FROM payments p
JOIN invoices inv ON p.invoice_id = inv.invoice_id
JOIN vendors v ON inv.vendor_id = v.vendor_id
ORDER BY actual_payment_cycle_days DESC;
