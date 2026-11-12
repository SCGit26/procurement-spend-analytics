-- ==========================================================
-- Spend Compliance & Spend Leakage SQL Query used to populate Looker
-- ==========================================================

-- 1. Preferred vs. MAVERICK SPEND ANALYSIS
-- Identifies total spend routed through preferred and non-preferred vendors along with payment status and time taken to process invoices.
SELECT 
    po.department,
    v.vendor_name,
    v.category,
    v.is_preferred_vendor,
    i.invoice_id,
    i.invoice_amount,
    i.match_status,
    i.payment_status,
    (i.goods_receipt_date - i.invoice_date) AS receipt_lag_days,
    (i.payment_date - i.invoice_date) AS total_cycle_days,
    i.invoice_date
FROM invoices_payments i
JOIN purchase_orders po ON i.po_id = po.po_id
JOIN vendors v ON i.vendor_id = v.vendor_id;
