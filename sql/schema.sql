-- ==========================================================
-- Procurement Spend Analytics & PTP Schema
-- Database: PostgreSQL
-- ==========================================================

-- Drop tables if they already exist (for clean resets during development)
DROP TABLE IF EXISTS invoices_payments CASCADE;
DROP TABLE IF EXISTS purchase_orders CASCADE;
DROP TABLE IF EXISTS vendors CASCADE;

-- 1. Vendors Table (Supplier Master Data)
CREATE TABLE vendors (
    vendor_id VARCHAR(10) PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL, -- e.g., 'IT Software', 'Office Supplies', 'Logistics'
    tax_id VARCHAR(20) UNIQUE NOT NULL,
    is_preferred_vendor BOOLEAN DEFAULT TRUE,
    country VARCHAR(50) DEFAULT 'USA'
);

-- 2. Purchase Orders Table (PO Header Data)
CREATE TABLE purchase_orders (
    po_id VARCHAR(15) PRIMARY KEY,
    vendor_id VARCHAR(10) REFERENCES vendors(vendor_id),
    order_date DATE NOT NULL,
    total_po_amount NUMERIC(12,2) NOT NULL,
    department VARCHAR(50) NOT NULL, -- e.g., 'Engineering', 'Operations', 'Finance'
    po_status VARCHAR(20) DEFAULT 'OPEN' -- 'OPEN', 'CLOSED', 'CANCELLED'
);

-- 3. Invoices & Payments Table (AP Transaction & Matching Data)
CREATE TABLE invoices_payments (
    invoice_id VARCHAR(15) PRIMARY KEY,
    po_id VARCHAR(15) REFERENCES purchase_orders(po_id),
    vendor_id VARCHAR(10) REFERENCES vendors(vendor_id),
    invoice_date DATE NOT NULL,
    goods_receipt_date DATE,
    payment_date DATE,
    invoice_amount NUMERIC(12,2) NOT NULL,
    match_status VARCHAR(25) NOT NULL, -- '3-Way Match Passed', 'Price Discrepancy', 'Maverick Spend'
    payment_status VARCHAR(20) NOT NULL -- 'Paid', 'Blocked', 'Pending Approval'
);

-- Create indexes for performance optimization on frequent query columns
CREATE INDEX idx_invoices_vendor ON invoices_payments(vendor_id);
CREATE INDEX idx_po_department ON purchase_orders(department);
CREATE INDEX idx_invoices_match_status ON invoices_payments(match_status);