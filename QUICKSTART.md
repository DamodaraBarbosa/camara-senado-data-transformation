# Quick Start - dbt + Athena

## Iniciar

```bash
cd /home/damodarabarbosa/projetos/camara-senado-data-transformation
source .venv/bin/activate
source .env
dbt debug      # esperado: All checks passed!
dbt ls
```

## Criar uma model de staging

1. Declare a tabela raw em `models/sources/raw.yml` (colunas e tipos; rascunho via `python scripts/infer_columns.py amostra.json`) e confira o manifesto com `python scripts/check_sources.py --allow-missing`.
2. Crie a tabela no Glue: `dbt run-operation create_raw_tables --args '{select: <bundle>__<name>}'`.
3. Crie `models/camara/<assunto>/staging/stg_<entidade>.sql` usando `{{ source('raw', '<bundle>__<name>') }}`. Veja `stg_votacoes.sql` como referência: cada ingestão é um snapshot completo, então o modelo mantém só o arquivo mais recente da partição mais recente.
4. Execute: `dbt build --select stg_<entidade>`.

A tag do assunto (`camara`, `<assunto>`) vem do `dbt_project.yml` pela pasta; não é preciso declarar no modelo.

## Comandos úteis

| Comando | O que faz |
|---|---|
| `dbt run` | Executa todas as models |
| `dbt run --select tag:votacoes` | Executa os modelos de um assunto |
| `dbt test` | Roda os testes |
| `dbt build` | run + test na ordem do DAG |
| `dbt compile` | Compila o SQL sem executar |
| `dbt docs generate && dbt docs serve` | Documentação em http://localhost:8000 |

## Ambientes

```bash
export DBT_DEFAULT_TARGET=dev    # padrão
export DBT_DEFAULT_TARGET=prod
```

O target define o bucket (`dataplatform-camara-<target>-db`) e o schema padrão (`-staging`).

## Convenções

- `stg_<entidade>`, `int_<transformação>`, `fato_<entidade>` / `dim_<entidade>`
- Sempre `source()` para dados brutos e `ref()` para outras models
- Testes `unique`/`not_null` na chave de cada staging

Mais detalhes: `README.md`, `SETUP.md`, `ATHENA_CONFIG.md`.
