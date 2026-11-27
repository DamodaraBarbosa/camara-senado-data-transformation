# 🚀 Guia de Setup - dbt + Athena

## Status Atual

- ✅ Estrutura de diretórios criada
- ✅ dbt_project.yml configurado
- ✅ profiles.yml pronto
- ✅ .env configurado com variáveis
- 🔄 Instalando dependências...

---

## Passo a Passo de Setup

### 1. Validar Virtual Environment

```bash
cd /home/damodarabarbosa/projetos/camara-senado-data-transformation
source .venv/bin/activate
python --version  # Deve ser Python 3.8+
```

### 2. Carregar Variáveis de Ambiente

```bash
source .env
echo $DBT_DEFAULT_TARGET  # Deve exibir "dev"
```

### 3. Testar dbt Debug

```bash
dbt debug
```

**Se houver erro de importação de Credentials:**
- Significa que o adapter Athena tem incompatibilidade com a versão do dbt
- Solução: Usar `dbt-athena-community` (mais atualizado) ou adapter alternativo

### 4. Testar Conexão com AWS

```bash
aws sts get-caller-identity
```

Deve retornar seu AWS Account ID: `904464083417`

---

## 🔧 Troubleshooting

### Erro: "cannot import name 'Credentials'"

**Causa:** Adapter dbt-athena desatualizado

**Solução 1 - Usar dbt-athena-community (Recomendado):**
```bash
pip uninstall dbt-athena -y
pip install dbt-athena-community
dbt debug
```

**Solução 2 - Usar adapter mais recente:**
```bash
pip install dbt-athena-community>=1.5.0
```

**Solução 3 - Usar versão exata compatível:**
```bash
pip install dbt-core==1.5.0 dbt-athena-community==1.5.0
```

---

### Erro: "Profile not found"

**Causa:** `profiles.yml` não está em `~/.dbt/` ou projeto

**Solução:**
```bash
# Opção 1: Usar profiles.yml local (recomendado)
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml

# Opção 2: Especificar localização
dbt debug --profiles-dir .
```

---

### Erro: "Cannot connect to Athena"

**Causa:** Credenciais AWS não configuradas

**Solução:**
```bash
# Configurar AWS CLI
aws configure

# Verificar credenciais
aws sts get-caller-identity

# Verificar acesso ao S3
aws s3 ls s3://dataplatform-senado-dev-db/
```

---

### Erro: "S3 staging directory not found"

**Causa:** Pasta não existe no S3

**Solução:**
```bash
# Criar pasta S3
aws s3api put-object --bucket dataplatform-senado-dev-db --key athena-results/

# Verificar
aws s3 ls s3://dataplatform-senado-dev-db/athena-results/
```

---

## ✅ Validação Final

Quando tudo estiver funcionando:

```bash
# 1. Validar conexão
dbt debug
# Esperado: All checks passed!

# 2. Listar models
dbt ls

# 3. Executar exemplo
dbt run --select example_staging

# 4. Verificar no S3
aws s3 ls s3://dataplatform-senado-dev-db/athena-results/
```

---

## 📌 Próximos Passos

1. ✅ Validar `dbt debug` passa
2. ✅ Criar primeira model em `models/staging/stg_<tabela>.sql`
3. ✅ Executar `dbt run`
4. ✅ Adicionar testes
5. ✅ Gerar documentação com `dbt docs generate`

---

## 📂 Estrutura de Modelos

Os modelos estão organizados por **assunto (subject)** e depois por **layer**:

```
models/camara/
├── votacoes/
│   ├── staging/       → Transformações iniciais (views)
│   ├── intermediate/  → Transformações intermediárias (tables)
│   └── marts/         → Tabelas finais - fatos e dimensões
├── frentes/           → Modelos de frentes parlamentares
├── deputados/         → Modelos de deputados
└── despesas/          → Modelos de despesas
```

**Executar por assunto:**
```bash
dbt run --select tag:votacoes
dbt run --select tag:deputados
dbt test --select tag:frentes
```

---

## 📚 Referências Úteis

- [dbt Athena Community Adapter](https://github.com/dbt-labs/dbt-athena)
- [dbt Docs - Adapters](https://docs.getdbt.com/docs/supported-data-platforms)
- [AWS Athena + dbt](https://docs.getdbt.com/reference/warehouse-setups/athena-setup)
- [AWS Glue Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)

---

**Última atualização:** 2026-11-27
