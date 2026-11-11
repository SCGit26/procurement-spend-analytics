# Enterprise Procurement Analytics & Spend Compliance Dashboard

## 📌 Executive Summary

This project delivers an end-to-end Procurement Analytics solution designed to provide executive visibility into organizational spending, preferred vendor compliance, and off-contract maverick spend leakage.

By ingesting raw transactional Procure-to-Pay (PTP) data into PostgreSQL, standardizing field-level schemas, and developing a dynamic 12-column executive dashboard in Looker Studio, this project enables procurement leadership to identify compliance gaps, optimize vendor relationships, and mitigate capital leakage.

## 🎯 Business Problem & Key Metrics

Unmanaged ("maverick") spend bypassing negotiated contract rates represents a major source of capital inefficiency in enterprise procurement. This dashboard addresses three core operational questions:

1. **Compliance Tracking:** What percentage of total spend flows through contracted, preferred suppliers?

2. **Leakage Distribution:** Which business departments and expense categories account for the highest volume of off-contract leakage?

3. **Vendor Exposure:** Which specific non-preferred suppliers represent the largest financial risk for targeted vendor consolidation?

### Key Performance Indicators (KPIs)

* **Total Spend (\$):** Aggregate invoice value processed across all business units ($\sum \text{invoice\_amount}$).

* **Preferred Vendor Rate (%):** Percentage of total spend executed through contracted vendors:
  

  $$
  \text{Preferred Vendor Rate \%} = \frac{\sum (\text{CASE WHEN } \text{is\_preferred\_vendor} = \text{'true'} \text{ THEN } \text{invoice\_amount ELSE } 0 \text{ END})}{\sum (\text{invoice\_amount})}
  $$

* **Maverick Spend (\$):** Total financial value of off-contract/unapproved invoices.

* **Avg Cycle Time (Days):** Mean operational duration from purchase requisition to invoice settlement ($\text{AVG}(\text{total\_cycle\_days})$).

## 📐 System & Dashboard Architecture

Before constructing the dashboard in Looker Studio, a formal 12-column wireframe was engineered in Lucidchart to ensure strict visual hierarchy, optimal cognitive ergonomics, and grid alignment for executive presentation.

### Architectural Wireframe

### Layout & Information Routing Standard

* **Tier 1 (Executive Summary Scorecards):** 4 high-level KPI cards spanning 3 grid columns each. Provides immediate top-line operational metrics.

* **Tier 2 (Distribution & Compliance Analysis):** Two 6-column side-by-side visual panels:

  * **Panel A (Left):** *Spend Compliance by Department* (Stacked Bar Chart sorting total spend vs. maverick leakage by department).

  * **Panel B (Right):** *Maverick Spend Leakage by Category* (Donut Chart filtered to isolate off-contract distribution across expense categories).

* **Tier 3 (Granular Vendor Exposure Table):** One full-width 12-column detail grid (**Panel C: Off-Contract Vendor Exposure & Leakage Summary**) detailing vendor-level exposure (`vendor_name`, `category`, `department`, `invoice_amount`).

## 🛠️ Data Pipeline & Schema Setup

### 1. Schema Configuration & Type Handling

To prevent data-type casting mismatches during Looker Studio aggregations (such as string-to-boolean errors or string summation failures), the data source schema was explicitly typed:

| Field Name | Source Type | Model Type | Applied Aggregation / Formatting | 
| ----- | ----- | ----- | ----- | 
| `invoice_id` | String | Text / Identifier | Count / Grouping | 
| `invoice_amount` | String (Formatted) | Numeric (Currency) | `SUM` / USD (\$) | 
| `is_preferred_vendor` | String (`'true'` / `'false'`) | Text | Case-insensitive String Matching | 
| `total_cycle_days` | Integer | Numeric | `AVG` | 
| `department` | String | Text | Dimension Grouping | 
| `category` | String | Text | Dimension Grouping | 

### 2. SQL Data Quality Checks (PostgreSQL)

```
-- Verification of Preferred vs. Maverick Spend Allocation
SELECT 
    LOWER(is_preferred_vendor) AS preferred_status,
    COUNT(invoice_id) AS invoice_count,
    SUM(invoice_amount) AS total_spend_usd,
    ROUND(SUM(invoice_amount) * 100.0 / SUM(SUM(invoice_amount)) OVER (), 2) AS spend_percentage
FROM ptp_analytics_portfolio
GROUP BY 1
ORDER BY total_spend_usd DESC;

```

## 📊 Dashboard Visual Mockup

> ![alt text](Procurement_&_PTP_Spend_Analytics_Dashboard.png)
>
> `![Final Looker Studio Dashboard](./dashboard/Procurement_&_PTP_Spend_Analytics_Dashboard.png)`

## 💻 Tech Stack & Tools Used

* **Database Engine:** PostgreSQL

* **BI & Data Visualization:** Looker Studio (Google Data Studio)

* **Wireframing & UI/UX Design:** Lucidchart

* **Documentation & Version Control:** Git, Markdown, GitHub

## 🚀 How to Replicate This Project

1. **Database Setup:** Run the SQL scripts in `/sql/schema.sql` to create the table schema and load raw PTP transactional data from `/data/mock_procurement_data.csv`.

2. **Data Connector:** Connect Looker Studio to the PostgreSQL database or import the sanitized CSV from `/data/ptp_analytics_facts.csv`.

3. **Type Mapping:** Ensure `invoice_amount` is mapped to **Numeric** $\rightarrow$ **Currency (USD)** and `is_preferred_vendor` is set to **Text**.

4. **Calculated Fields:** Create the `Preferred Vendor Rate %` metric using the string-safe case statement provided in the metric documentation.

5. **Layout Alignment:** Assemble panels according to the 12-column grid specified in `/dashboard/procurement_dashboard_wireframe.png`.