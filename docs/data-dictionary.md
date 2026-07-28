# Data dictionary

## Raw and staging domains

| Domain | Natural grain | Representative fields |
| --- | --- | --- |
| Customers | One row per customer | customer ID, location, signup date, gender, age group, acquisition channel |
| Geography | One row per ZIP/location mapping | ZIP, city, region, district |
| Inventory | One row per snapshot and product | stock on hand, units received/sold, stockout days, days of supply, fill rate, reorder flags |
| Order items | One row per order-product line | quantity, unit price, discount, promotion IDs |
| Orders | One row per order | order date, customer, status, payment method, device, source |
| Payments | One row per order payment record | payment method, value, installments |
| Products | One row per product | name, category, segment, size, color, price, COGS |
| Promotions | One row per promotion | type, discount, active dates, category, channel, minimum order value |
| Returns | One row per return record | order, product, date, reason, quantity, refund |
| Reviews | One row per review | order, product, customer, date, rating, title |
| Daily sales | One row per date | revenue, COGS |
| Shipments | One row per order shipment | ship date, delivery date, shipping fee |
| Web traffic | One row per date and source | sessions, visitors, page views, bounce rate, session duration |

Raw tables retain source values as `NVARCHAR`. Staging tables use typed SQL
columns and `TRY_CONVERT`-style loading should quarantine or log invalid source
values instead of silently coercing them.

## Dimensions

| Dimension | Business key |
| --- | --- |
| `dwh.dim_date` | full date / `YYYYMMDD` date key |
| `dwh.dim_geography` | ZIP/location mapping |
| `dwh.dim_customer` | customer ID |
| `dwh.dim_product` | product ID |
| `dwh.dim_promotion` | promotion ID |
| `dwh.dim_payment_method` | payment-method label |
| `dwh.dim_device` | device label |
| `dwh.dim_order_source` | order-source label |
| `dwh.dim_return_reason` | return-reason label |

Unknown members should use stable surrogate keys and explicit labels such as
`Unknown` or `No promotion`.

## Power BI marts

| Mart | Intended grain | Primary use |
| --- | --- | --- |
| `vw_sales_overview_daily` | One row per date | Orders, customers, quantity, revenue, profit, AOV, and status |
| `vw_revenue_reconciliation` | One row per date | Reconcile daily sales-file revenue with order-item revenue |
| `vw_product_performance` | One row per product | Sales, profit, returns, reviews, and rating |
| `vw_customer_geography` | Geography-demographic-channel aggregate | Customer count, orders, revenue, profit, and AOV |
| `vw_return_analysis` | Return date-product-location-reason aggregate | Return rows, returned units, refunds, and days to return |
| `vw_inventory_health` | One row per snapshot and product | Inventory balance, sell-through, fill rate, and exception flags |
| `vw_traffic_sales_daily` | One row per date | Sessions, page views, bounce rate, revenue, and revenue/session |
| `vw_web_traffic_by_source` | One row per date and source | Channel-level traffic performance |
| `vw_ai_return_risk_prediction` | One row per sales order item | Actual return label, predicted probability, flag, and risk band |

## Metric grain cautions

- Daily distinct customer counts are not additive across dates.
- Inventory balances are semi-additive: aggregate across products, but not by
  summing historical snapshots.
- Rates and averages are non-additive and must be recalculated from weighted
  components at the requested filter grain.
- A customer/product mart should not be joined directly to another fact-like
  mart unless the relationship grain and cardinality are explicitly proven.
