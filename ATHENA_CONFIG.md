# Athena + dbt Configuration

## Infraestrutura

- Região: `us-east-1`; workgroup: `primary`
- Buckets: `dataplatform-camara-{dev,prod}-db` (dados em `raw/`, resultados do Athena em `athena-results/`, saídas do dbt em `dbt/`)
- Databases Glue por ambiente: `dataplatform-camara-{dev,prod}-db-{raw,staging,intermediate,marts}`
- Existem também os equivalentes `dataplatform-senado-*`, ainda sem dados raw e fora do escopo atual do projeto.

## Configuração local

### `.env` (gitignored)

```bash
export DBT_DEFAULT_TARGET=dev
export DEV_BUCKET=dataplatform-camara-dev-db
export DEV_REGION=us-east-1
export DEV_WORKGROUP=primary
export PROD_BUCKET=dataplatform-camara-prod-db
export PROD_REGION=us-east-1
export PROD_WORKGROUP=primary
```

### `profiles.yml` (gitignored)

Copie de `profiles.yml.example`. Cada target usa `database: awsdatacatalog` e `schema: <BUCKET>-staging`; `s3_staging_dir` e `s3_data_dir` derivam do bucket.

### Autenticação AWS

`aws configure` (credenciais em `~/.aws/credentials`) ou as variáveis `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`. No CI, role OIDC por ambiente.

## Camada raw

As tabelas Glue de `raw/` são criadas pelo dbt (`dbt run-operation create_raw_tables`) a partir de `models/sources/raw.yml`. Veja a seção "Catálogo Glue da camada raw" no `README.md`.

## Notas

1. Athena cobra por bytes escaneados.
2. `create_raw_tables` faz `DROP`/`CREATE` de metadado: confira o target antes de rodar.
3. Views não aceitam `"$file_modified_time"` no Athena; use `table` nos modelos que dependem dele.
