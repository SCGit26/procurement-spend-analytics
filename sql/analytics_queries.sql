-- ==========================================================
-- Procurement Analytics & Spend Leakage SQL Queries
-- ==========================================================

-- 1. MAVERICK SPEND ANALYSIS
-- Identifies total spend routed through non-preferred vendors or unapproved channels
SELECT 
    v.vendor_id,
    v.vendor_name,
    v.category,
    v.is_preferred_vendor,
    COUNT(i.invoice_id) AS total_invoices_processed,
    SUM(i.invoice_amount) AS total_maverick_spend
FROM invoices_payments i
JOIN vendors v ON i.vendor_id = v.vendor_id
WHERE v.is_preferred_vendor = FALSE 
   OR i.match_status = 'Maverick Spend'
GROUP BY v.vendor_id, v.vendor_name, v.category, v.is_preferred_vendor
ORDER BY total_maverick_spend DESC;


-- 2. AVERAGE PTP CYCLE TIME ANALYSIS
-- Measures operational efficiency: the average duration (in days) from Invoice Receipt to Payment Disbursement by Department
SELECT 
    po.department,
    COUNT(i.invoice_id) AS invoices_paid,
    ROUND(AVG(i.payment_date - i.invoice_date), 1) AS avg_cycle_time_days,
    MIN(i.payment_date - i.invoice_date) AS min_cycle_time_days,
    MAX(i.payment_date - i.invoice_date) AS max_cycle_time_days
FROM invoices_payments i
JOIN purchase_orders po ON i.po_id = po.po_id
WHERE i.payment_status = 'Paid' 
  AND i.payment_date IS NOT NULL
GROUP BY po.department
ORDER BY avg_cycle_time_days DESC;