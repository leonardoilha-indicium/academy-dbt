# Notes for BI (Power BI)

Points of the model that affect the report. Building the Power BI file is not part of this repository.

## Relationships

| From (fact or bridge) | To | Cardinality |
|---|---|---|
| `fact_sales.nk_product` | `dim_products.sk_product` | many to one |
| `fact_sales.nk_customer` | `dim_customers.sk_customer` | many to one |
| `fact_sales.dt_order` | `dim_dates.sk_date` | many to one |
| `fact_sales.fk_geography` | `dim_geographies.sk_geography` | many to one |
| `fact_sales.nk_credit_card` | `dim_credit_cards.sk_credit_card` | many to one |
| `fact_sales.nk_order_status` | `dim_order_statuses.sk_order_status` | many to one |
| `bridge_order_sales_reasons.nk_sales_reason` | `dim_sales_reasons.sk_sales_reason` | many to one |
| `fact_sales.nk_sales_order` | `bridge_order_sales_reasons.nk_sales_order` | many to many |

## Modeling attention points

- **Sales reason is many-to-many.** `nk_sales_order` is not unique on either side. In Power BI this relationship must be handled (for example, a many-to-many relationship with the filter flowing from the bridge to the fact, or a table of distinct orders in the middle). Filtering one reason does not duplicate rows; grouping by reason counts an order with two reasons in both, and the total exceeds the fact total. Do not show a grand total in the view by reason.
- **Orders are a distinct count.** Use `DISTINCTCOUNT(fact_sales[nk_sales_order])`. The sum of orders by product exceeds the total of orders, because an order has several products.
- **Average ticket** = net revenue divided by the distinct count of orders in the filter context. Do not use an average of a column.
- **Additive measures:** sum only `qt_order`, `vl_gross`, `vl_discount` and `vl_net`. The fact has no unit price or discount rate, on purpose, because they are not additive.
- **Gross sales** = `SUM(vl_gross)`, the audited value (2011 = US$ 12,646,112.16). Net revenue is `SUM(vl_net)`.
- **Values with many decimal places:** `vl_discount` and `vl_net` have 8 decimal places so no precision is lost. Format with 2 decimal places in the presentation.

## Data and period

- Orders go from 2011-05-31 to 2014-06-30. 2011 (May to December) and 2014 (January to June) are partial years, and June 2014 is incomplete (about US$ 49 thousand). Year over year comparisons must use the same range of months, and a warning in the report is advisable.
- All orders have the status "Shipped" (5). A status filter will have no practical effect.
- `dim_dates` covers 2011-01-01 to 2014-12-31. It should be marked as a date table.
- The channel (`is_online_order`) matches the customer type: every online order is from a person and every salesperson order is from a store. Avoid crossing the two as if they were independent.
- Salesperson orders appear only in some months of 2014 and do not exist after May 2014.

## Items outside the current model

- **Territory:** `dim_customers` has only `nk_territory` (an identifier), without a name. For the revenue by territory KPI, `salesterritory` must be added to staging and a dimension created. Today the geographic view uses the ship-to country.
- **Freight and tax:** they exist only in the order header and are not in the fact. If the dashboard needs them, a `fact_orders` at order grain is required.
- **"Promotion" reason:** the question uses the reason "On Promotion", the only one of type "Promotion".
- **Column names:** they follow prefixes (`sk_`, `nk_`, `nm_`, `vl_`, `qt_`, `dt_`, `ds_`, `cd_`, `nr_`, `pc_`, `is_`). Rename them to friendly names in Power BI.
