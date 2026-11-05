# Notes for BI (Power BI)

Points of the model that affect the report. Building the Power BI file is not part of this repository.

## Tables

| Table | Grain | Use |
|---|---|---|
| `fact_sales` | One order line | Quantity, gross, discount, net, cost and margin amounts by product, customer, date, geography, card and status |
| `fact_orders` | One order | Subtotal, tax, freight, total due and days to ship, by customer, salesperson, territory, shipping method and dates |
| `fact_sales_quota` | One salesperson and quota period | Quota and net sales achieved in the period |
| `bridge_order_sales_reasons` | One order and reason | Links orders to sales reasons |
| 10 dimensions | One member | `dim_products`, `dim_customers`, `dim_dates`, `dim_geographies`, `dim_credit_cards`, `dim_order_statuses`, `dim_salespersons`, `dim_territories`, `dim_ship_methods` and `dim_sales_reasons` |

All `sk_` and `fk_` columns are hashed text keys. Hide them in the report view and rename the other columns to friendly names (they follow prefixes: `nk_`, `nm_`, `vl_`, `qt_`, `dt_`, `ds_`, `cd_`, `nr_`, `pc_`, `is_`).

## Relationships

| From | To | Cardinality | Note |
|---|---|---|---|
| `fact_sales.fk_product` | `dim_products.sk_product` | many to one | |
| `fact_sales.fk_customer` | `dim_customers.sk_customer` | many to one | |
| `fact_sales.fk_order_date` | `dim_dates.sk_date` | many to one | |
| `fact_sales.fk_geography` | `dim_geographies.sk_geography` | many to one | |
| `fact_sales.fk_credit_card` | `dim_credit_cards.sk_credit_card` | many to one | |
| `fact_sales.fk_order_status` | `dim_order_statuses.sk_order_status` | many to one | |
| `fact_orders.fk_customer` | `dim_customers.sk_customer` | many to one | |
| `fact_orders.fk_sales_person` | `dim_salespersons.sk_sales_person` | many to one | |
| `fact_orders.fk_territory` | `dim_territories.sk_territory` | many to one | |
| `fact_orders.fk_ship_method` | `dim_ship_methods.sk_ship_method` | many to one | |
| `fact_orders.fk_credit_card` | `dim_credit_cards.sk_credit_card` | many to one | |
| `fact_orders.fk_order_status` | `dim_order_statuses.sk_order_status` | many to one | |
| `fact_orders.fk_geography` | `dim_geographies.sk_geography` | many to one | |
| `fact_orders.fk_order_date` | `dim_dates.sk_date` | many to one | Active |
| `fact_orders.fk_due_date` | `dim_dates.sk_date` | many to one | Inactive, use `USERELATIONSHIP` |
| `fact_orders.fk_ship_date` | `dim_dates.sk_date` | many to one | Inactive, use `USERELATIONSHIP` |
| `fact_sales_quota.fk_sales_person` | `dim_salespersons.sk_sales_person` | many to one | |
| `fact_sales_quota.fk_quota_start_date` | `dim_dates.sk_date` | many to one | Active |
| `fact_sales_quota.fk_quota_end_date` | `dim_dates.sk_date` | many to one | Inactive, use `USERELATIONSHIP` |
| `fact_orders.nk_sales_order` | `fact_sales.nk_sales_order` | one to many | Order to its lines |
| `fact_orders.nk_sales_order` | `bridge_order_sales_reasons.nk_sales_order` | one to many | Order to its reasons |
| `bridge_order_sales_reasons.fk_sales_reason` | `dim_sales_reasons.sk_sales_reason` | many to one | |

`dim_dates` is a role-playing dimension. Only one date relationship per fact is active; the others (due date, ship date and quota end date) need `USERELATIONSHIP` in the measures, or a copy of the date table.

## Modeling attention points

- **Sales reason is many-to-many.** `nk_sales_order` is unique in `fact_orders`, so the bridge links to `fact_orders` (one to many) and `fact_orders` links to `fact_sales` (one to many). This avoids a direct many-to-many relationship, but the filter from the bridge to `fact_orders` and then to `fact_sales` must flow against the usual direction, which needs a bidirectional relationship on those two links. Filtering one reason does not duplicate rows; grouping by reason counts an order with two reasons in both, and the total exceeds the fact total. Do not show a grand total in the view by reason.
- **Do not mix the grains.** Freight, tax and total due are in `fact_orders` (order grain) and must never be spread over the order lines of `fact_sales`. Product, category and quantity exist only in `fact_sales`. A visual that mixes an order-level measure with a product attribute would repeat the order amount for each line.
- **Orders are a distinct count.** In `fact_sales`, use `DISTINCTCOUNT(fact_sales[nk_sales_order])`. In `fact_orders`, a row count is enough. The sum of orders by product exceeds the total of orders, because an order has several products.
- **Average ticket** = net revenue divided by the distinct count of orders in the filter context. Do not use an average of a column.
- **Additive measures:** sum only `qt_order`, `vl_gross`, `vl_discount`, `vl_net`, `vl_cost` and `vl_margin` in `fact_sales`, `vl_subtotal`, `vl_tax`, `vl_freight` and `vl_total_due` in `fact_orders`, and `vl_sales_quota`, `qt_orders` and `vl_net_sales` in `fact_sales_quota`. The facts have no unit price or discount rate, on purpose, because they are not additive. `qt_days_to_ship` is a per-order value: use an average.
- **Gross sales** = `SUM(fact_sales[vl_gross])`, the audited value (2011 = US$ 12,646,112.16). Net revenue is `SUM(fact_sales[vl_net])`, which equals `SUM(fact_orders[vl_subtotal])` (the difference is 0.004 in total, from source rounding).
- **Margin percentage** = `SUM(vl_margin) / SUM(vl_net)`, calculated in a measure and never summed. Overall it is about 11.4% (US$ 12.6 million of margin on US$ 109.8 million of net revenue). `vl_margin` can be negative: about 18% of the lines are sold below the standard cost, so a margin by category or product can be negative.
- **Quota attainment** = `SUM(vl_net_sales) / SUM(vl_sales_quota)` in `fact_sales_quota`. It is a ratio, so calculate it in a measure and never store or sum it. The overall attainment is about 84% (US$ 80.5 million sold against US$ 95.7 million of quota).
- **Values with many decimal places:** `vl_discount` and `vl_net` have 8 decimal places so no precision is lost. Format with 2 decimal places in the presentation.

## Data and period

- Orders go from 2011-05-31 to 2014-06-30. 2011 (May to December) and 2014 (January to June) are partial years, and June 2014 is incomplete (about US$ 49 thousand). Year over year comparisons must use the same range of months, and a warning in the report is advisable.
- All orders have the status "Shipped" (5). A status filter will have no practical effect.
- `dim_dates` covers 2011-01-01 to 2014-12-31. It should be marked as a date table.
- The channel (`is_online_order`) matches the customer type: every online order is from a person and every salesperson order is from a store. Avoid crossing the two as if they were independent.
- Only salesperson orders have a salesperson. Online orders point to the "No salesperson" member of `dim_salespersons`, so sales by salesperson must filter that member out.
- Salesperson orders appear only in some months of 2014 and do not exist after May 2014.
- The days to ship are almost constant (about 7 days on average, at most 8), so they carry little analytical weight.
- The cost is the standard cost, not the real purchase or production cost. It is the cost valid on the order date; 64 lines (0.05%) have no cost row for their date and use the standard cost of the product catalog.
- Quota periods are quarterly (12 quota dates, from 2011-05-31 to 2014-03-01). The latest quota ends at the last order date of the data, not at a real quarter end.

## Not modeled yet

- **Special offers:** the discount of each line is not linked to a promotion program, so the "Promotion" reason is the only promotion signal.
- **Territory of customers and salespeople:** `dim_customers` and `dim_salespersons` keep only `nk_territory`, as an attribute, without a relationship to `dim_territories`. Revenue by territory uses `fact_orders.fk_territory`.
- **"Promotion" reason:** the question uses the reason "On Promotion", the only one of type "Promotion".
