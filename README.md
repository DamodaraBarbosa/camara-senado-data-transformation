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
│   ├── staging/       → Transformações iniciais (views por padrão)
│   ├── intermediate/  → Transformações intermediárias (tables)
│   └── marts/         → Modelos finais de negócio (tables)
├── tests/             → Testes de qualidade de dados (SQL, dbt)
├── seeds/             → Dados estáticos (CSVs)
├── macros/            → Macros e funções reutilizáveis
├── snapshots/         → Histórico de mudanças
├── analyses/          → Análises ad-hoc (não são materializadas)
├── dbt_project.yml    → Configurações do projeto
├── profiles.yml       → Conexão com Athena (⚠️ gitignored)
└── .env               → Variáveis de ambiente (⚠️ gitignored)
```

---

## ⚙️ Configuração de Ambientes

### DEV (padrão)
- Database: `dataplatform-senado-dev-db-raw`
- S3: `s3://dataplatform-senado-dev-db/athena-results/`

### PROD
- Database: `dataplatform-senado-prod-db-raw`
- S3: `s3://dataplatform-senado-prod-db/athena-results/`

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
dbt run --select tag:staging
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

| Tipo | Padrão | Exemplo |
|------|--------|---------|
| Staging Models | `stg_<entidade>` | `stg_deputados` |
| Intermediate | `int_<transformação>` | `int_deputados_agregados` |
| Marts | `fato_<entidade>` / `dim_<entidade>` | `fato_votos`, `dim_deputados` |
| Tests | Descritivo em snake_case | `test_id_nunca_null` |
| Seeds | `seed_<nome>` | `seed_municipios.csv` |

---

## 🗄️ Configuração de Database/Schema

Cada modelo pode ser materializado em um database diferente usando:

```sql
{{ config(
    database='dataplatform-senado-dev-db-staging',
    materialized='table'
) }}

SELECT * FROM ...
```

---

## ⚠️ Notas Importantes

1. **ANSI Mode Desativado**: Athena tem suporte limitado a ANSI SQL - já está desativado em `profiles.yml`
2. **Custos**: Athena cobra por bytes escaneados - otimize suas queries
3. **S3 Staging Dir**: Certificar que a pasta `s3://dataplatform-senado-dev-db/athena-results/` existe
4. **Credentials**: Nunca fazer commit de `profiles.yml` ou `.env` - já estão em `.gitignore`

---

## 📚 Documentação de Referência

- [dbt Documentation](https://docs.getdbt.com)
- [dbt Athena Adapter](https://github.com/dbt-labs/dbt-athena)
- [AWS Athena Docs](https://docs.aws.amazon.com/athena/)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)

---

## 🤝 Próximos Passos

1. Criar primeira model em `models/staging/stg_<entidade>.sql`
2. Executar com `dbt run`
3. Verificar resultados em `s3://dataplatform-senado-dev-db/athena-results/`
4. Adicionar testes em `tests/`

---

**Última atualização**: 2026-11-27
