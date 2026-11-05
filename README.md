# Adventure Works Analytics Engineering

Analytics Engineer certification project (Indicium). The goal is to build a dimensional data warehouse for the commercial area of Adventure Works, with reliable and auditable data, and to deliver a dashboard that answers the business questions.

## Stack

- Data warehouse: Databricks Free Edition (Unity Catalog, serverless SQL Warehouse)
- Transformation: dbt (dbt Cloud, and dbt Core with the `dbt-databricks` adapter for local development)
- BI: Power BI Desktop
- Version control: GitHub

## Architecture

The 64 SAP Adventure Works CSVs are in `seeds/sap_adventure_works/` and are loaded with `dbt seed` into the `adventure_works` schema of the `adventure_works_dw` catalog. This is the only source schema of the challenge.

| Layer | Schema | Materialization | Content |
|---|---|---|---|
| Raw (seeds) | `adventure_works` | table | Original SAP tables |
| Staging | `staging` | view | One `stg_*` model per source table, only renaming, casting and cleaning |
| Marts | `marts` | table | `dim_*` dimensions, `bridge_*` bridge and `fact_sales` fact consumed by Power BI |

The custom schema is used exactly as written, thanks to the macro `macros/generate_schema_name.sql`.

## Dimensional model

The `fact_sales` fact has one row per sales order line. The dimensions are `dim_products`, `dim_customers`, `dim_dates`, `dim_geographies`, `dim_credit_cards`, `dim_order_statuses` and `dim_sales_reasons`. The many-to-many relationship between orders and sales reasons is solved by the bridge table `bridge_order_sales_reasons`.

Gross sales is `sum(unitprice * orderqty)` before discounts, and in 2011 it matches the audited value of US$ 12,646,112.16. The full design, the source of each table and the diagram are in `docs/modelo_conceitual.md`.

## Structure

```
models/
  staging/      sales, production, person (sources, stg_* models and one yml per model)
  marts/        sales, production, person, common (dimensions, bridge and fact)
analyses/       exploratory queries (eda_*)
docs/           business rules, KPIs, conceptual model and notes for BI
tests/          singular tests (for example, 2011 gross sales against the audited value)
macros/         generate_schema_name
seeds/          Adventure Works CSVs
```

## Conventions

Column names use a prefix by type: `sk_` (surrogate key), `nk_` (natural key), `fk_` (composite foreign key), `dt_` (date), `nm_` (name), `ds_` (description), `cd_` (code), `nr_` (number), `qt_` (quantity), `vl_` (value), `pc_` (percentage) and `is_` (boolean). Models and columns follow the Indicium SQL and dbt style guide (CTEs, leading commas, one yml per model, descriptions in English).

## Documentation

- `docs/regras_de_negocio.md`: metric definitions, formulas and modeling decisions
- `docs/kpis.md`: commercial KPIs and the decision each one changes
- `docs/modelo_conceitual.md`: star schema in Mermaid and the source of each table
- `docs/notas_para_bi.md`: points of the model that affect Power BI

## How to run

```
dbt deps
dbt seed
dbt run
dbt test --select source:*
dbt test
```

To load a specific table: `dbt seed -s csv_name`.

If `dbt seed` keeps running indefinitely after loading the 64 tables, restart the dbt Cloud IDE (three dots in the corner of the command line, `Restart IDE`) and load in batches.

The queries in `analyses/` can be run with `dbt show --select analysis_name`.

## Data quality

- Source tests: `unique` and `not_null` on keys, including `salesorderdetailid` to detect load duplicates, and `relationships` between tables
- Primary key tests (`unique` and `not_null`) and relationship tests between the fact and the dimensions
- Quality tests: value ranges and same row count as the detail (`equal_rowcount`), to make sure no join duplicated data
- Singular test that compares 2011 gross sales with the audited value of US$ 12,646,112.16

## Security

Databricks access tokens are never versioned. The connection is configured in dbt Cloud and, locally, in `~/.dbt/profiles.yml`, outside the repository, with the token coming from an environment variable.
