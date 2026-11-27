# ⚡ Quick Start - dbt + Athena

## ✅ Status: Pronto para Usar!

Seu projeto dbt está totalmente configurado e conectado ao AWS Athena.

---

## 🚀 Iniciar em 3 Passos

### 1️⃣ Ativar Virtual Environment
```bash
cd /home/damodarabarbosa/projetos/camara-senado-data-transformation
source .venv/bin/activate
source .env
```

### 2️⃣ Verificar Conexão
```bash
dbt debug
# Esperado: "All checks passed!"
```

### 3️⃣ Listar Models Disponíveis
```bash
dbt ls
```

---

## 📝 Criar Sua Primeira Model

### Passo 1: Criar arquivo SQL
Crie um arquivo em `models/staging/stg_<tabela>.sql`:

```sql
{{ config(
    materialized='view',
    tags=['staging']
) }}

SELECT
    id,
    nome,
    created_at
FROM {{ source('raw', 'minha_tabela') }}
```

### Passo 2: Executar dbt
```bash
dbt run --select stg_minha_tabela
```

### Passo 3: Verificar Resultado
```bash
aws s3 ls s3://dataplatform-senado-dev-db/athena-results/
```

---

## 🔥 Comandos Mais Úteis

| Comando | O que faz |
|---------|----------|
| `dbt run` | Executa todas as models |
| `dbt run --select stg_*` | Executa models com tag staging |
| `dbt test` | Roda testes de qualidade |
| `dbt docs generate` | Gera documentação |
| `dbt docs serve` | Abre docs em http://localhost:8000 |
| `dbt clean` | Remove arquivos temporários |
| `dbt compile` | Compila SQL sem executar |

---

## 📊 Estrutura de Pastas

```
models/
  ├── staging/       → Views de transformações iniciais
  ├── intermediate/  → Tables de transformações intermediárias
  └── marts/         → Tables finais de negócio (fatos e dimensões)
tests/               → Testes de qualidade (SQL e dbt)
seeds/               → Arquivos CSV estáticos
macros/              → Funções e helpers reutilizáveis
```

---

## 🌍 Mudar de Ambiente

### DEV (padrão)
```bash
export DBT_DEFAULT_TARGET=dev
dbt run
```

### PROD
```bash
export DBT_DEFAULT_TARGET=prod
dbt run
```

---

## ⚙️ Configurações Importantes

### Database/Schema por Model
```sql
{{ config(
    database='dataplatform-senado-dev-db-staging',
    schema='producao'
) }}
```

### Materializações Disponíveis
- `view` - Consulta no Athena (rápida, sem custo de armazenamento)
- `table` - Tabela física no S3 (mais lenta, custo de storage)
- `incremental` - Atualização incremental (otimizado)

---

## 📚 Exemplo de Model Completa

**Arquivo: `models/marts/fato_votos.sql`**

```sql
{{ config(
    materialized='table',
    database='dataplatform-senado-dev-db-marts',
    tags=['marts']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['data_voto', 'id_deputado']) }} as sk_voto,
    data_voto,
    id_deputado,
    id_proposicao,
    voto,
    COUNT(*) as qtd_votos
FROM {{ ref('stg_votos') }}
GROUP BY 1, 2, 3, 4, 5
```

---

## 🧪 Adicionar Testes

**Arquivo: `tests/test_fato_votos.sql`**

```sql
-- Testa se não há IDs duplicadas
SELECT *
FROM {{ ref('fato_votos') }}
GROUP BY sk_voto
HAVING COUNT(*) > 1
```

Executar testes:
```bash
dbt test
```

---

## 📖 Converter para Markdown

Depois de criar models e testes:

```bash
dbt docs generate
dbt docs serve
```

Abre documentação em http://localhost:8000

---

## ⚠️ Dicas Importantes

1. **Sempre usar `source()` para dados brutos:**
   ```sql
   FROM {{ source('raw', 'tabela_original') }}
   ```

2. **Sempre usar `ref()` para referenciar outras models:**
   ```sql
   FROM {{ ref('stg_tabela') }}
   ```

3. **Nomear models com prefixo:**
   - `stg_` para staging
   - `int_` para intermediate
   - `fato_` ou `dim_` para marts

4. **Adicionar testes nas colunas principais:**
   ```sql
   - name: id
     tests:
       - unique
       - not_null
   ```

---

## 🆘 Troubleshooting

### "Connection failed"
```bash
aws configure
aws sts get-caller-identity
```

### "Schema/Database not found"
```bash
aws s3 ls s3://dataplatform-senado-dev-db/
```

### "S3 staging directory not found"
```bash
aws s3api put-object --bucket dataplatform-senado-dev-db --key athena-results/
```

---

## 📌 Próximas Etapas

1. ✅ Criar `models/staging/stg_<primeiro_dado>.sql`
2. ✅ Executar `dbt run`
3. ✅ Criar testes em `tests/`
4. ✅ Adicionar documentação
5. ✅ Configurar CI/CD (opcional)

---

**Pronto para começar!** 🚀

Para mais informações, veja:
- `README.md` - Documentação completa
- `SETUP.md` - Troubleshooting detalhado
- `ATHENA_CONFIG.md` - Configuração da infraestrutura AWS
