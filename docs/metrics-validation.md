# Metric definitions and validated snapshot

The figures below were recomputed from the data embedded in
`powerbi/FashionDW.pbix`. They provide sanity-check targets after rebuilding the
Power BI measures.

| Metric | Definition | Validated value |
| --- | --- | ---: |
| Order-item rows | Rows in the return-risk analytical mart | 714,669 |
| Orders | Sum of daily distinct orders | 646,945 |
| Customers | Distinct customer IDs | 90,246 |
| Products | Distinct product IDs | 2,412 |
| Quantity sold | Sum of order-item quantity | 3,213,143 |
| Net revenue | Gross revenue less discounts | 15,680,870,563.22 |
| Gross profit | Net revenue less estimated COGS | 1,517,418,828.32 |
| Profit margin | Gross profit / net revenue | 9.68% |
| Average order value | Net revenue / orders | 24,238.34 |
| Return records | Rows in the return mart | 39,939 |
| Returned quantity | Sum of returned units | 109,586 |
| Returned quantity rate | Returned quantity / quantity sold | 3.41% |
| Refund amount | Sum of refund amount | 510,598,534.92 |
| Average days to return | Return-row-weighted average | 17.97 |
| Latest stock on hand | Stock at the 2022-12-31 snapshot | 104,235 |
| Web sessions | Sum of daily sessions | 91,452,537 |
| Page views | Sum of daily page views | 396,662,800 |

## Important grain rules

- Do not sum `total_customers` from the daily sales mart to calculate all-time
  unique customers. That produces customer-days, not distinct customers.
- Do not sum stock-on-hand across snapshots. Use the latest snapshot inside the
  selected filter context.
- Calculate margin from additive numerator and denominator measures. Do not sum
  daily or product-level margin percentages.
- Weight average rating by `total_reviews`.
- Weight average days to return by `return_rows`.
- Weight bounce rate by sessions when aggregating across traffic sources.

## Return-risk baseline

The embedded prediction snapshot is an experimental baseline, not a
production-ready classifier.

| Metric | Value |
| --- | ---: |
| Positive rate | 5.59% |
| Accuracy at threshold 0.60 | 85.02% |
| Precision | 11.06% |
| Recall | 23.89% |
| F1 | 15.12% |
| ROC AUC | 0.621 |
| PR AUC | 0.084 |

Because a no-return classifier would have high accuracy on this imbalanced
dataset, ROC AUC, PR AUC, precision, recall, and business cost should be used
instead of accuracy alone.
