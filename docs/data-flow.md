# Architecture and Data Flow

![Fashion E-Commerce Analytics Warehouse architecture](/images/Architecture_Warehouse.png)

## Where the data comes from

The pipeline begins with operational extracts from 13 business domains. The
local files may be CSV, Excel, or exports from transactional systems and are
placed under `data/raw/` for loading. Raw data is intentionally excluded from
version control.

| Domain | Typical business content |
| --- | --- |
| Customers | Customer identifiers, profile attributes, acquisition information |
| Geography | Country, region, city, and location mappings |
| Products | SKU, category, brand, pricing, and product attributes |
| Promotions | Campaign, promotion type, discount, and validity dates |
| Orders | Order header, customer, status, source, and order date |
| Order items | Product-level quantity, price, discount, revenue, and cost |
| Payments | Payment method, amount, status, and payment time |
| Shipments | Carrier, shipping status, and delivery timestamps |
| Returns | Returned item, reason, quantity, refund, and return date |
| Reviews | Product rating, review attributes, and review date |
| Inventory | Product stock by snapshot date |
| Daily sales | Daily operational sales aggregates |
| Web traffic | Sessions, users, source/channel, and engagement metrics |

## End-to-end flow

| Step | Input | Processing | Output and control |
| ---: | --- | --- | --- |
| 1 | Operational extracts | Collect files for the 13 source domains | Local source files under `data/raw/` |
| 2 | Source files | Load source values without business transformation | `raw.*` tables retain values as `NVARCHAR` for traceability |
| 3 | Raw tables | Trim, standardize labels, deduplicate, and safely convert dates, money, numbers, and flags | Typed and cleaned `stg.*` tables |
| 4 | Staging tables | Run 32 null, uniqueness, referential-integrity, and business-rule checks | Results go to `dq.data_quality_log`; critical failures stop the refresh |
| 5 | Quality-approved staging data | Resolve surrogate keys and load conformed dimensions and fact tables at explicit grains | Dimensional model under `dwh.*` |
| 6 | Warehouse dimensions and facts | Join, aggregate, and calculate business metrics for stable reporting grains | Nine report-ready views under `mart.*` |
| 7 | Analytical marts | Import and refresh the semantic model | Seven bookmark-driven Power BI report views |
| 8 | Governed warehouse data | Build 30 return-risk features and train an interpretable logistic-regression baseline in Python | Model metrics, coefficients, probabilities, and risk labels under `ml.*` |
| 9 | Scored model output | Publish return-risk results through `mart.vw_ai_return_risk_prediction` | Power BI AI view for exploratory prioritization |

## Controls and failure behavior

- `scripts/run_sql_pipeline.py` orchestrates staging, data quality, dimensions,
  facts, marts, and ML objects.
- The runner performs a preflight check and refuses to execute required SQL
  files that are missing or empty.
- `audit.etl_run` and `audit.etl_step_log` capture run and step status,
  duration, row counts, and errors.
- A warning is logged for review. A critical data-quality failure raises an
  error and prevents downstream warehouse and dashboard refreshes.

## Power BI consumption layer

Power BI imports nine report-facing marts rather than querying raw operational
tables. This separates source-system structure from business-facing metrics and
keeps report grains explicit:

1. `mart.vw_sales_overview_daily`
2. `mart.vw_revenue_reconciliation`
3. `mart.vw_return_analysis`
4. `mart.vw_product_performance`
5. `mart.vw_inventory_health`
6. `mart.vw_customer_geography`
7. `mart.vw_traffic_sales_daily`
8. `mart.vw_web_traffic_by_source`
9. `mart.vw_ai_return_risk_prediction`

The resulting dashboard views cover Overview, Sales & Profit, Product,
Customer & Geography, Return Analysis, Inventory & Web Traffic, and AI Return
Risk.
