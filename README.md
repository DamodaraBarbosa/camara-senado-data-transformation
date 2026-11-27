# Câmara & Senado - Data Transformation (dbt)

Projeto de transformação de dados usando **dbt** com **AWS Athena** como data warehouse.

## 📋 Pré-requisitos

- Python 3.8+
- AWS CLI configurado (`aws configure`)
- Acesso às bases de dados no AWS Athena

## 🚀 Setup Local

### 1. Ativar Virtual Environment

```bash
source .venv/bin/activate
```

### 2. Instalar Dependências

```bash
pip install -r requirements.txt
```

### 3. Carregar Variáveis de Ambiente

```bash
source .env
```

### 4. Verificar Configuração

```bash
dbt debug
```

Você deve ver uma mensagem de sucesso indicando que a conexão com Athena está funcionando.

---

## 📁 Estrutura do Projeto

```
├── models/
│   └── camara/                          → Modelos por assunto
│       ├── votacoes/
│       │   ├── staging/                 → Views iniciais
│       │   ├── intermediate/            → Tables de transformação
│       │   └── marts/                   → Tables finais (fatos/dimensões)
│       ├── frentes/
│       │   ├── staging/
│       │   ├── intermediate/
│       │   └── marts/
│       └── deputados/ ... (10 assuntos, mesma estrutura)
├── models/sources/raw.yml               → Declaração das tabelas raw (colunas e tipos)
├── catalog/raw_tables.json              → Manifesto das tabelas raw (cópia do repo de ingestão)
├── scripts/                             → check_sources.py, infer_columns.py
├── tests/                               → Testes de qualidade de dados
├── seeds/                               → Dados estáticos (CSVs)
├── macros/                              → Macros e funções reutilizáveis
├── snapshots/                           → Histórico de mudanças
├── analyses/                            → Análises ad-hoc
├── dbt_project.yml                      → Configurações do projeto
├── profiles.yml                         → Conexão com Athena (⚠️ gitignored)
└── .env                                 → Variáveis de ambiente (⚠️ gitignored)
```

**Lógica de organização:**
- **Por Assunto (Subject)**: 10 temas (blocos, deputados, eventos, frentes, grupos, legislaturas, orgaos, partidos, proposicoes, votacoes)
- **Por Layer**: staging → intermediate → marts (todas materializadas como table)

---

## 🧊 Catálogo Glue da camada raw

O repositório dbt cria e versiona as tabelas Glue de `raw/` (tabelas externas JSON com *partition projection* por `ingestion_date`). A ingestão não tem etapa de catálogo.

```bash
# Cria/recria as tabelas raw declaradas em models/sources/raw.yml (DROP + CREATE; só metadado)
dbt run-operation create_raw_tables                                 # todas
dbt run-operation create_raw_tables --args '{select: votacoes__votacoes}'   # uma
```

| Evento | Ação |
|---|---|
| Nova ingestão semanal (partição nova) | Nenhuma (partition projection) |
| Extractor novo/removido | Atualizar `catalog/raw_tables.json` e `raw.yml` |
| Coluna nova/removida/tipo alterado | Atualizar `raw.yml` e rodar `create_raw_tables` |

- Nome da tabela: `{bundle}__{name}`; dados em `raw/{bundle}/{name}/ingestion_date=YYYY-MM-DD/*.json` (NDJSON).
- O bucket é derivado do target (macro `raw_bucket()` → `dataplatform-camara-<target>-db`).
- `python scripts/infer_columns.py amostra.json` gera um rascunho de colunas; revise antes de commitar.
- `python scripts/check_sources.py` valida `raw.yml` contra o manifesto (`--allow-missing` durante a migração por bundle).
- Todas as 60 tabelas do manifesto estão declaradas em `raw.yml`; o CI exige correspondência total.
- Colunas que são array na API ficam como `string` (JSON texto): use `json_parse`/`try_cast` no staging. O SerDe devolve as chaves internas em minúsculas.
- `orgaos__codigo_situacao` e `orgaos__situacoes_orgao` gravam um único array JSON por arquivo (não NDJSON). Elas usam `meta: {format: text}` e uma coluna `payload` com a linha inteira; faça `json_parse(payload)` no staging. Idealmente a ingestão passaria a gravar NDJSON.
- `deputados__discursos`, `__eventos`, `__historico` e `__mandatos_externos` não tinham dados na migração: as colunas vêm da documentação da API (tudo `string`, exceto ids) e devem ser revalidadas com `infer_columns.py` quando houver dados.

---

## ⚙️ Configuração de Ambientes

Variáveis em `.env` (gitignored): `DBT_DEFAULT_TARGET`, `DEV_BUCKET`, `PROD_BUCKET` (e opcionalmente `*_REGION`, `*_WORKGROUP`).

### DEV (padrão)
- Bucket: `dataplatform-camara-dev-db`
- Databases: `dataplatform-camara-dev-db-{raw,staging,intermediate,marts}`

### PROD
- Bucket: `dataplatform-camara-prod-db`
- Databases: `dataplatform-camara-prod-db-{raw,staging,intermediate,marts}`

O schema padrão do target é o database `-staging`. `create_raw_tables` faz `DROP`/`CREATE` de tabelas: confira o target antes de rodar.

**Para alternar ambiente:**
```bash
# Trocar para PROD
export DBT_DEFAULT_TARGET=prod

# Executar dbt
dbt run
```

---

## 🔧 Comandos Úteis

### Validar Conexão
```bash
dbt debug
```

### Executar Todas as Models
```bash
dbt run
```

### Executar Model Específica
```bash
dbt run --select model_name
```

### Executar com Tag
```bash
dbt run --select tag:votacoes
```

### Executar Tests
```bash
dbt test
```

### Compilar SQL (sem executar)
```bash
dbt compile
```

### Limpar Arquivos Temporários
```bash
dbt clean
```

### Gerar Documentação
```bash
dbt docs generate
dbt docs serve
```

---

## 📝 Convenções de Nomenclatura

| Tipo | Padrão | Exemplo | Localização |
|------|--------|---------|-------------|
| Staging Models | `stg_<entidade>` | `stg_votos` | `models/camara/votacoes/staging/` |
| Intermediate | `int_<transformação>` | `int_votos_agregados` | `models/camara/votacoes/intermediate/` |
| Marts | `fato_<entidade>` / `dim_<entidade>` | `fato_votos`, `dim_deputados` | `models/camara/votacoes/marts/` |
| Tests | Descritivo em snake_case | `test_id_nunca_null` | `tests/` |
| Seeds | `seed_<nome>` | `seed_municipios.csv` | `seeds/` |

**Organização de Assuntos (Subjects):**
- `models/camara/blocos/` - Blocos parlamentares
- `models/camara/deputados/` - Dados dos deputados
- `models/camara/eventos/` - Eventos parlamentares
- `models/camara/frentes/` - Frentes parlamentares
- `models/camara/grupos/` - Grupos parlamentares
- `models/camara/legislaturas/` - Legislaturas
- `models/camara/orgaos/` - Órgãos parlamentares
- `models/camara/partidos/` - Partidos políticos
- `models/camara/proposicoes/` - Proposições legislativas
- `models/camara/votacoes/` - Votações parlamentares

---

## 🗄️ Configuração de Database/Schema

Cada modelo pode ser materializado em um database diferente usando:

```sql
{{ config(
    schema='dataplatform-camara-dev-db-intermediate',
    materialized='table'
) }}

SELECT * FROM ...
```

---

## ⚠️ Notas Importantes

1. **ANSI Mode Desativado**: Athena tem suporte limitado a ANSI SQL - já está desativado em `profiles.yml`
2. **Custos**: Athena cobra por bytes escaneados - otimize suas queries
3. **S3 Staging Dir**: Certificar que a pasta `s3://<bucket>/athena-results/` existe
4. **Credentials**: Nunca fazer commit de `profiles.yml` ou `.env` - já estão em `.gitignore`

---

## 📚 Documentação de Referência

- [dbt Documentation](https://docs.getdbt.com)
- [dbt Athena Adapter](https://github.com/dbt-labs/dbt-athena)
- [AWS Athena Docs](https://docs.aws.amazon.com/athena/)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)

---

## 🤝 Próximos Passos

1. Migrar os demais bundles para `models/sources/raw.yml` (um por PR) e criar seus `stg_*`
2. Remover `--allow-missing` do CI ao concluir
3. Configurar `+schema` de intermediate e marts quando houver modelos

---

**Última atualização**: 2026-11-27
