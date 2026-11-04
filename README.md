# Adventure Works Analytics Engineering

Projeto da certificação de Analytics Engineer (Indicium). O objetivo é construir um data warehouse dimensional para a área comercial da Adventure Works, com dados confiáveis e auditáveis, e entregar um dashboard que responda às perguntas do negócio.

## Stack

- Data warehouse: Databricks Free Edition (Unity Catalog, SQL Warehouse serverless)
- Transformação: dbt Cloud
- BI: Power BI Desktop
- Versionamento: GitHub

## Arquitetura

Os 64 CSVs do SAP Adventure Works ficam em `seeds/sap_adventure_works/` e são carregados com `dbt seed` no schema `adventure_works` do catálogo `adventure_works_dw`. Esse é o único schema de origem do desafio.

| Camada | Schema | Materialização | Conteúdo |
|---|---|---|---|
| Raw (seeds) | `adventure_works` | tabela | Tabelas originais do SAP |
| Staging | `staging` | view | Um modelo `stg_*` por tabela de origem, só renomeação, cast e limpeza |
| Intermediate | `staging` | ephemeral | Regras intermediárias (ex.: motivos de venda por pedido) |
| Marts | `marts` | tabela | Dimensões `dim_*` e fato `fct_sales` consumidas pelo Power BI |

O schema customizado é usado exatamente como escrito, graças à macro `macros/generate_schema_name.sql`.

## Estrutura

```
models/
  staging/
  intermediate/
  marts/
tests/        testes singulares (ex.: valor de vendas brutas de 2011)
macros/       generate_schema_name
seeds/        CSVs do Adventure Works
```

## Como rodar

```
dbt deps
dbt seed
dbt run
dbt test --select source:*
dbt test
```

Para carregar uma tabela específica: `dbt seed -s nome_do_csv`.

Se o `dbt seed` ficar rodando indefinidamente depois de carregar as 64 tabelas, reinicie a IDE do dbt Cloud (três pontos no canto da linha de comando, `Restart IDE`) e carregue em lotes.

## Qualidade de dados

- Testes de source e de chave primária (`unique` e `not_null`) nas dimensões e na fato
- Testes de qualidade nos modelos
- Teste singular que compara as vendas brutas de 2011 com o valor auditado de US$ 12.646.112,16

## Segurança

Tokens de acesso do Databricks nunca são versionados. A conexão é configurada no dbt Cloud.
