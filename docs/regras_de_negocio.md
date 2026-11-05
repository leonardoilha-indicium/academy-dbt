# Business rules

This document defines each metric of the model in business language, with its formula, source table and the modeling decisions taken. The only data source is the `adventure_works` schema (SAP Adventure Works seeds).

## Grain

There are three fact tables:

- `fact_sales` has one row per **sales order line** (`salesorderdetailid`). The order (`salesorderid`) is kept in the fact as a degenerate dimension (`nk_sales_order`). An order has several lines, so the number of orders is never summed: it is always a distinct count.
- `fact_orders` has one row per **sales order**. It holds the header amounts (subtotal, tax, freight and total due) and the days to ship.
- `fact_sales_quota` has one row per **salesperson and quota period**. It holds the quota and the net sales achieved in the period.

## Metrics

| Metric | Business definition | Formula | Model column | Source |
|---|---|---|---|---|
| Gross sales | Amount sold before discounts | `sum(unitprice * orderqty)` | `fact_sales.vl_gross` | `salesorderdetail` |
| Discount | Amount granted in the order lines | `unitprice * orderqty * unitpricediscount` | `fact_sales.vl_discount` | `salesorderdetail` |
| Net revenue | Gross sales minus discounts | `sum(unitprice * orderqty * (1 - unitpricediscount))` | `fact_sales.vl_net` | `salesorderdetail` |
| Quantity | Units sold | `sum(orderqty)` | `fact_sales.qt_order` | `salesorderdetail` |
| Orders | Distinct orders in the period | `count(distinct salesorderid)` | `fact_sales.nk_sales_order` | `salesorderheader` and `salesorderdetail` |
| Average ticket | Net revenue per order | `net revenue / distinct orders` in the period | calculated in the query or in the BI | fact |
| Items per order | Units per order | `quantity / distinct orders` | calculated in the query or in the BI | fact |
| Discount rate | Share of gross sales that became discount | `discount / gross sales` | calculated in the query or in the BI | fact |
| Subtotal | Order amount net of discounts | `subtotal` of the order header | `fact_orders.vl_subtotal` | `salesorderheader` |
| Tax | Tax charged in the order | `taxamt` of the order header | `fact_orders.vl_tax` | `salesorderheader` |
| Freight | Freight charged in the order | `freight` of the order header | `fact_orders.vl_freight` | `salesorderheader` |
| Total due | Amount the customer owes | `subtotal + tax + freight` | `fact_orders.vl_total_due` | `salesorderheader` |
| Days to ship | Days between order and shipment | `ship date - order date` | `fact_orders.qt_days_to_ship` | `salesorderheader` |
| Sales quota | Sales target of a salesperson for the period | `salesquota` of the quota history | `fact_sales_quota.vl_sales_quota` | `salespersonquotahistory` |
| Net sales in the quota period | Subtotal of the salesperson orders in the period | `sum(subtotal)` of the orders in the period | `fact_sales_quota.vl_net_sales` | `fact_orders` |
| Quota attainment | Share of the quota that was sold | `net sales / quota` | calculated in the query or in the BI | `fact_sales_quota` |

The average ticket of a product is the net revenue of the product divided by the distinct orders in which the product appears in that period (month, year, city, state or country).

## Decisions

### 1. Definition of "gross sales"

Three different values could be called sales. In 2011 they are:

| Definition | 2011 value (US$) | Note |
|---|---|---|
| `sum(unitprice * orderqty)` at order line level | **12,646,112.16** | The value audited by the CEO. This is the one chosen |
| Header `subtotal` | 12,641,672.21 | Already net of discounts |
| Header `totaldue` | 14,155,699.52 | Includes tax and freight |

Gross sales is `sum(unitprice * orderqty)`, before discounts. The singular test `tests/assert_gross_sales_2011_matches_audit.sql` fails if the fact differs from 12,646,112.16 by more than 0.01. The 2011 `subtotal` matches the net revenue of the fact (12,641,672.21), which confirms the net formula.

### 2. Sales reasons (many-to-many)

`salesorderheadersalesreason` links each order to zero, one or more reasons (8,453 orders with no reason, 18,530 with one, 4,329 with two and 153 with three). A direct join with the fact would duplicate revenue.

The bridge table `bridge_order_sales_reasons` was created, with one row per order and reason, linked to the fact by `nk_sales_order`. Orders without a reason point to the "No reason" member (`-1`) of `dim_sales_reasons`, so every order appears in the bridge (36,100 rows: 27,647 source pairs plus 8,453 orders without a reason).

Consequences:
- Filtering **one** reason does not duplicate any fact row, because the order and reason pair is unique (tested).
- Grouping **by reason** counts an order with two reasons in both. The sum across reasons exceeds the fact total, by design. Values must not be summed across reasons.
- The question "product with the most units under the Promotion reason" uses the reason named "On Promotion", the only one of type "Promotion". Result: Water Bottle - 30 oz., with 546 units.

### 3. Duplicate in the `salesorderdetail` seed load

The load of the `salesorderdetail` seed produced duplicated rows. **[FILL IN: how it was fixed, for example reloading the seed or removing the repeated rows.]** After the fix, the table has 121,317 rows and 121,317 distinct `salesorderdetailid` values. The `unique` test on `salesorderdetailid` in the source and the `equal_rowcount` test of the fact against staging catch any future load duplicate.

### 4. City, state and country

They come from the order **ship-to address** (`shiptoaddressid`) through `address`, `stateprovince` and `countryregion`. The geography is at city level within a state or province, so that cities with the same name in different states are not mixed.

### 5. Customer type and name

A customer can be a person (`personid`) or a store (`storeid`). 635 customers have both filled in. Rule: when there is a store, the customer is of type **Store**, the name is the store name and the person name goes to `nm_contact`. Without a store, the customer is **Person**, with the full name of the person.

### 6. Order status

The source has no status table. Codes 1 to 6 (in process, approved, backordered, rejected, shipped, cancelled) are defined in `dim_order_statuses`. All orders in the data have status 5 (shipped).

### 7. Freight and tax

`freight` and `taxamt` exist only in the order header, so they cannot be summed at line level without allocation. They live in `fact_orders`, at order grain, together with the subtotal and the total due, and are never copied to `fact_sales`. In `fact_orders`, the total due is the subtotal plus tax plus freight, and the sum of the subtotals matches the net revenue of `fact_sales` (a difference of 0.004 in total, from source rounding). Order level amounts must not be mixed with product attributes, which exist only at line level.

### 8. Orders without a credit card

Orders without `creditcardid` point to the "Unknown" member (`-1`) of `dim_credit_cards`, so no rows are lost and the relationship does not break.

### 9. Data period

Orders go from 2011-05-31 to 2014-06-30. Therefore 2011 (May to December) and 2014 (January to June) are partial years, and June 2014 is clearly incomplete. Year over year comparisons need the same period in both years.

### 10. Keys and column names

| Prefix | Type | Example |
|---|---|---|
| `sk_` | Surrogate primary key, always a hash | `sk_product` |
| `nk_` | Natural key from the source | `nk_product` |
| `fk_` | Foreign key, the `sk_` of a dimension | `fk_product` |
| `dt_` | Date | `dt_order` |
| `nm_` | Name | `nm_product` |
| `ds_` | Description or attribute text | `ds_card_type` |
| `cd_` | Code | `cd_state_province` |
| `nr_` | Number | `nr_year` |
| `qt_` | Quantity | `qt_order` |
| `vl_` | Monetary value | `vl_gross` |
| `pc_` | Percentage | `pc_unit_price_discount` |
| `is_` | Boolean | `is_online_order` |

Every `sk_` is created with `generate_surrogate_key` over the natural key, in the model that owns the key (the dimension, or the fact for its own primary key). A foreign key is never hashed in the fact: the fact joins the dimension by the natural key and takes the `sk_` of the dimension as `fk_`. The facts keep only the natural keys of their own grain (`nk_sales_order` and `nk_sales_order_detail`). The date dimension is used several times by the same fact (`fk_order_date`, `fk_due_date`, `fk_ship_date`, `fk_quota_start_date` and `fk_quota_end_date`).

### 11. Sales quota

`salespersonquotahistory` has one quota per salesperson and quota date (quarterly, from 2011-05-31 to 2014-03-01, for 17 salespeople). A quota applies from its date until the day before the next quota of the same salesperson, and the latest quota applies until the last order date of the data. The net sales of the period are the order subtotals of the salesperson orders placed in it. All 3,806 salesperson orders fall in some quota period (US$ 80,487,704.18 in total). Online orders have no salesperson and are not part of the quota. Quota attainment is a ratio and is calculated outside the fact; overall, the net sales are about 84% of the quota (US$ 80.5 million against US$ 95.7 million).

## Quality controls

- Source tests: `unique` and `not_null` on keys (including `salesorderdetailid`) and `relationships` between tables.
- Staging and marts tests: `unique` and `not_null` on keys, `relationships` between the fact and the dimensions, `accepted_values` on the customer type.
- Range and consistency tests on the fact: `accepted_range` on quantity and amounts, and row count equal to the detail (`equal_rowcount`).
- Singular audit test: 2011 gross sales equal to 12,646,112.16.
