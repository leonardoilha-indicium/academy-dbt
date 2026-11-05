# Conceptual model (star schema)

The `fact_sales` fact sits in the center, at sales order line grain. The dimensions link to the fact through the natural key (`nk_`) or, for geography, through a composite key (`fk_geography`). Sales reasons link through a bridge table, because the relationship is many-to-many.

## Diagram

```mermaid
erDiagram
    fact_sales {
        int sk_sales_order_detail PK
        int nk_sales_order_detail
        int nk_sales_order
        int nk_product FK
        int nk_customer FK
        int nk_credit_card FK
        int nk_order_status FK
        string fk_geography FK
        date dt_order FK
        boolean is_online_order
        int qt_order
        decimal vl_gross
        decimal vl_discount
        decimal vl_net
    }

    dim_products {
        int sk_product PK
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
        int sk_customer PK
        int nk_customer
        string ds_customer_type
        string nm_customer
        string nm_contact
        int nk_territory
    }

    dim_dates {
        date sk_date PK
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
        int sk_credit_card PK
        int nk_credit_card
        string ds_card_type
    }

    dim_order_statuses {
        int sk_order_status PK
        int nk_order_status
        string nm_order_status
    }

    bridge_order_sales_reasons {
        string sk_order_sales_reason PK
        int nk_sales_order
        int nk_sales_reason FK
    }

    dim_sales_reasons {
        int sk_sales_reason PK
        int nk_sales_reason
        string nm_sales_reason
        string ds_sales_reason_type
    }

    dim_products ||--o{ fact_sales : "nk_product"
    dim_customers ||--o{ fact_sales : "nk_customer"
    dim_dates ||--o{ fact_sales : "dt_order"
    dim_geographies ||--o{ fact_sales : "fk_geography"
    dim_credit_cards ||--o{ fact_sales : "nk_credit_card"
    dim_order_statuses ||--o{ fact_sales : "nk_order_status"
    fact_sales }o--o{ bridge_order_sales_reasons : "nk_sales_order"
    dim_sales_reasons ||--o{ bridge_order_sales_reasons : "nk_sales_reason"
```

## Source of each table

All sources are in the `adventure_works` schema. The `staging` layer has one `stg_` model per source table.

| Model table | Source tables (`adventure_works` schema) | Note |
|---|---|---|
| `fact_sales` | `salesorderdetail`, `salesorderheader`, `address` | Order line grain. Geography comes from the ship-to address |
| `dim_products` | `product`, `productsubcategory`, `productcategory` | Product with subcategory and category |
| `dim_customers` | `customer`, `store`, `person` | Store when there is a `storeid`, person otherwise |
| `dim_dates` | No source (generated with `dbt_utils.date_spine`) | From 2011-01-01 to 2014-12-31 |
| `dim_geographies` | `address`, `stateprovince`, `countryregion` | City, state and country |
| `dim_credit_cards` | `creditcard` | Plus the "Unknown" member (`-1`) |
| `dim_order_statuses` | No source (codes defined in the model) | Codes 1 to 6 of the header `status` |
| `dim_sales_reasons` | `salesreason` | Plus the "No reason" member (`-1`) |
| `bridge_order_sales_reasons` | `salesorderheader`, `salesorderheadersalesreason` | An order without a reason points to "No reason" |

## Reading the model

- **Fact:** `fact_sales` holds additive measures (`qt_order`, `vl_gross`, `vl_discount`, `vl_net`). The number of orders is a distinct count of `nk_sales_order`.
- **Dimensions:** each one has a `sk_` primary key. In single-column dimensions, the `sk_` is the renamed natural key.
- **Bridge:** `bridge_order_sales_reasons` links orders to reasons. The sum by reason does not match the fact total, by design.
