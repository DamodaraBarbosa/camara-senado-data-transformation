# Athena + dbt Configuration

## 🏗️ Infraestrutura Validada

Sua infraestrutura foi validada via AWS CLI em 2026-09-18.

### Workgroups
- ✅ **primary** (workgroup padrão do Athena)

### Databases Disponíveis
```
Senado:
  ├── dataplatform-senado-dev-db-raw
  ├── dataplatform-senado-dev-db-staging
  ├── dataplatform-senado-dev-db-intermediate
  ├── dataplatform-senado-dev-db-marts
  ├── dataplatform-senado-prod-db-raw
  ├── dataplatform-senado-prod-db-staging
  ├── dataplatform-senado-prod-db-intermediate
  └── dataplatform-senado-prod-db-marts

Câmara (também disponível):
  ├── dataplatform-camara-dev-db-raw
  ├── dataplatform-camara-dev-db-staging
  ├── dataplatform-camara-dev-db-intermediate
  ├── dataplatform-camara-dev-db-marts
  ├── dataplatform-camara-prod-db-raw
  ├── dataplatform-camara-prod-db-staging
  ├── dataplatform-camara-prod-db-intermediate
  └── dataplatform-camara-prod-db-marts
```

### S3 Buckets
- ✅ `s3://dataplatform-senado-dev-db/`
- ✅ `s3://dataplatform-senado-prod-db/`
- ✅ `s3://dataplatform-camara-dev-db/`
- ✅ `s3://dataplatform-camara-prod-db/`

### AWS Account
- Account ID: `904464083417`
- IAM User: `damodarabarbosa-admin`
- Region: `us-east-1`

---

## 🔧 Configuração Local

### 1. Arquivo `.env`
Variáveis de ambiente carregadas automaticamente para dev/prod:

```bash
# Current setup:
export DBT_DEFAULT_TARGET=dev
export DEV_CATALOG_NAME=AwsDataCatalog
export DEV_SCHEMA_NAME=dataplatform-senado-dev-db-raw
export DEV_S3_STAGING_DIR=s3://dataplatform-senado-dev-db/athena-results/
# ... and PROD equivalents
```

### 2. Arquivo `profiles.yml`
dbt profile configurado para Athena com:
- ✅ Catalog: `AwsDataCatalog` (Glue Catalog)
- ✅ Database: Configurável por env var
- ✅ S3 Staging Dir: Configurável por env var
- ✅ Region: us-east-1
- ✅ Workgroup: primary
- ✅ ANSI Mode: disabled (recomendado para Athena)
- ✅ Threads: 16
- ✅ Timeout: 300s

### 3. Autenticação AWS

**Opção 1 (Recomendada):** AWS CLI Local
```bash
aws configure
# Use sua IAM user credentials
```

dbt irá usar automaticamente as credenciais configuradas no `~/.aws/credentials`.

**Opção 2:** Variáveis de Ambiente
```bash
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
```

---

## ✅ Próximos Passos

1. **Testar conexão dbt com Athena:**
   ```bash
   dbt debug
   ```

2. **Criar primeira model:**
   ```bash
   dbt init models
   dbt run --select model_name
   ```

3. **Verificar resultados:**
   ```bash
   # Resultados das queries no S3:
   aws s3 ls s3://dataplatform-senado-dev-db/athena-results/
   ```

4. **Para mudar database por modelo:**
   - Usar `{{ database }}` no config do modelo
   - Exemplo: `dataplatform-senado-dev-db-staging`

---

## 📚 Referências

- [dbt Athena Adapter](https://github.com/dbt-labs/dbt-athena)
- [AWS Athena Documentation](https://docs.aws.amazon.com/athena/)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)

---

## ⚠️ Notas Importantes

1. **ANSI Mode**: Desativado por padrão - Athena tem suporte limitado
2. **S3 Staging Dir**: Criar a pasta manualmente se não existir
3. **Workgroup Configuration**: O workgroup `primary` pode ter limites de throughput
4. **Costs**: Athena cobra por bytes escaneados - otimize suas queries

---

*Last validated: 2026-09-18 by Claude Code*
