# Conceptual model (star schema)

The model has three fact tables, ten dimensions and one bridge table. `fact_sales` (order line grain) and `fact_orders` (order grain) share the same dimensions, and `fact_sales_quota` (salesperson and quota period grain) measures the sales against the quotas. Sales reasons link through a bridge table, because the relationship is many-to-many.

## Keys

- **`sk_`**: surrogate primary key of every table. It is a hash created with `generate_surrogate_key` over the natural key, in the model that owns the key.
- **`nk_`**: natural key from the source. The facts keep only the natural keys of their own grain (`nk_sales_order` and `nk_sales_order_detail`).
- **`fk_`**: foreign key. It is never hashed in the fact: the fact joins the dimension by the natural key and takes the `sk_` of the dimension.

## Diagram

```mermaid
erDiagram
    fact_sales {
        string sk_sales_order_detail PK
        int nk_sales_order_detail
        int nk_sales_order
        string fk_product FK
        string fk_customer FK
        string fk_order_date FK
        string fk_geography FK
        string fk_credit_card FK
        string fk_order_status FK
        date dt_order
        boolean is_online_order
        int qt_order
        decimal vl_gross
        decimal vl_discount
        decimal vl_net
    }

    fact_orders {
        string sk_sales_order PK
        int nk_sales_order
        string fk_customer FK
        string fk_sales_person FK
        string fk_territory FK
        string fk_ship_method FK
        string fk_credit_card FK
        string fk_order_status FK
        string fk_geography FK
        string fk_order_date FK
        string fk_due_date FK
        string fk_ship_date FK
        date dt_order
        date dt_due
        date dt_ship
        boolean is_online_order
        int qt_days_to_ship
        decimal vl_subtotal
        decimal vl_tax
        decimal vl_freight
        decimal vl_total_due
    }

    fact_sales_quota {
        string sk_sales_quota PK
        string fk_sales_person FK
        string fk_quota_start_date FK
        string fk_quota_end_date FK
        date dt_quota_start
        date dt_quota_end
        decimal vl_sales_quota
        int qt_orders
        decimal vl_net_sales
    }

    dim_products {
        string sk_product PK
        int nk_product
        string nm_product
        string cd_product
        string ds_color
        decimal vl_list_price
        decimal vl_standard_cost
        string nm_product_subcategory
        string nm_product_category
    }

    dim_customers {
        string sk_customer PK
        int nk_customer
        string ds_customer_type
        string nm_customer
        string nm_contact
        int nk_territory
    }

    dim_dates {
        string sk_date PK
        date dt_calendar
        int nr_year
        int nr_quarter
        int nr_month
        string nm_month
        string ds_year_month
        int nr_day_of_month
        int nr_day_of_week
        string nm_day_of_week
        boolean is_weekend
    }

    dim_geographies {
        string sk_geography PK
        string nm_city
        int nk_state_province
        string cd_state_province
        string nm_state_province
        string cd_country_region
        string nm_country_region
    }

    dim_credit_cards {
        string sk_credit_card PK
        int nk_credit_card
        string ds_card_type
    }

    dim_order_statuses {
        string sk_order_status PK
        int nk_order_status
        string nm_order_status
    }

    dim_salespersons {
        string sk_sales_person PK
        int nk_sales_person
        string nm_sales_person
        int nk_territory
    }

    dim_territories {
        string sk_territory PK
        int nk_territory
        string nm_territory
        string nm_territory_group
        string cd_country_region
        string nm_country_region
    }

    dim_ship_methods {
        string sk_ship_method PK
        int nk_ship_method
        string nm_ship_method
        decimal vl_ship_base
        decimal vl_ship_rate
    }

    dim_sales_reasons {
        string sk_sales_reason PK
        int nk_sales_reason
        string nm_sales_reason
        string ds_sales_reason_type
    }

    bridge_order_sales_reasons {
        string sk_order_sales_reason PK
        int nk_sales_order
        string fk_sales_reason FK
    }

    dim_products ||--o{ fact_sales : "fk_product"
    dim_customers ||--o{ fact_sales : "fk_customer"
    dim_dates ||--o{ fact_sales : "fk_order_date"
    dim_geographies ||--o{ fact_sales : "fk_geography"
    dim_credit_cards ||--o{ fact_sales : "fk_credit_card"
    dim_order_statuses ||--o{ fact_sales : "fk_order_status"

    dim_customers ||--o{ fact_orders : "fk_customer"
    dim_salespersons ||--o{ fact_orders : "fk_sales_person"
    dim_territories ||--o{ fact_orders : "fk_territory"
    dim_ship_methods ||--o{ fact_orders : "fk_ship_method"
    dim_credit_cards ||--o{ fact_orders : "fk_credit_card"
    dim_order_statuses ||--o{ fact_orders : "fk_order_status"
    dim_geographies ||--o{ fact_orders : "fk_geography"
    dim_dates ||--o{ fact_orders : "fk_order_date"
    dim_dates ||--o{ fact_orders : "fk_due_date"
    dim_dates ||--o{ fact_orders : "fk_ship_date"

    dim_salespersons ||--o{ fact_sales_quota : "fk_sales_person"
    dim_dates ||--o{ fact_sales_quota : "fk_quota_start_date"
    dim_dates ||--o{ fact_sales_quota : "fk_quota_end_date"

    fact_orders ||--o{ fact_sales : "nk_sales_order"
    fact_orders ||--o{ bridge_order_sales_reasons : "nk_sales_order"
    dim_sales_reasons ||--o{ bridge_order_sales_reasons : "fk_sales_reason"
```

`dim_dates` is a role-playing dimension: it links three times to `fact_orders` (order, due and ship dates) and twice to `fact_sales_quota` (start and end of the quota period).

## Source of each table

All sources are in the `adventure_works` schema. The `staging` layer has one `stg_` model per source table.

| Model table | Source tables (`adventure_works` schema) | Note |
|---|---|---|
| `fact_sales` | `salesorderdetail`, `salesorderheader`, `address` | Order line grain. Geography comes from the ship-to address |
| `fact_orders` | `salesorderheader`, `address` | Order grain. The only place with freight, tax and the days to ship |
| `fact_sales_quota` | `salespersonquotahistory`, plus the net sales from `fact_orders` | Salesperson and quota period grain |
| `dim_products` | `product`, `productsubcategory`, `productcategory` | Product with subcategory and category |
| `dim_customers` | `customer`, `store`, `person` | Store when there is a `storeid`, person otherwise |
| `dim_dates` | No source (generated with `dbt_utils.date_spine`) | From 2011-01-01 to 2014-12-31 |
| `dim_geographies` | `address`, `stateprovince`, `countryregion` | City, state and country |
| `dim_credit_cards` | `creditcard` | Plus the "Unknown" member (`-1`) |
| `dim_order_statuses` | No source (codes defined in the model) | Codes 1 to 6 of the header `status` |
| `dim_salespersons` | `salesperson`, `person` | Plus the "No salesperson" member (`-1`) for online orders |
| `dim_territories` | `salesterritory`, `countryregion` | Territory with sales group and country |
| `dim_ship_methods` | `shipmethod` | Shipping methods with base charge and rate |
| `dim_sales_reasons` | `salesreason` | Plus the "No reason" member (`-1`) |
| `bridge_order_sales_reasons` | `salesorderheader`, `salesorderheadersalesreason` | An order without a reason points to "No reason" |

## Reading the model

- **Facts:** `fact_sales` and `fact_orders` are linked by the order (`nk_sales_order`). Freight and tax exist only in `fact_orders` and must not be mixed with the line amounts of `fact_sales`. The number of orders is a distinct count of `nk_sales_order` in `fact_sales`, or a row count in `fact_orders`.
- **Quota:** `fact_sales_quota` holds the quota (`vl_sales_quota`) and the net sales of the salesperson in the same period (`vl_net_sales`, taken from the order subtotal in `fact_orders`). Quota attainment is `vl_net_sales / vl_sales_quota`, calculated in the query or in the BI. All 3,806 salesperson orders fall in some quota period, and online orders have no salesperson.
- **Dimensions:** each one has a hashed `sk_` primary key. `dim_customers` and `dim_salespersons` keep `nk_territory` as an attribute, without a foreign key to `dim_territories`.
- **Bridge:** `bridge_order_sales_reasons` links orders to reasons. The sum by reason does not match the fact total, by design.

## Not modeled yet

Product cost and margin, and special offers (discount programs), are not in the repository and are not in the diagram.
