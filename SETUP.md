# Setup e Troubleshooting - dbt + Athena

## Passo a passo

```bash
source .venv/bin/activate
pip install -r requirements.txt
cp profiles.yml.example profiles.yml   # apenas na primeira vez
source .env                            # veja ATHENA_CONFIG.md
aws sts get-caller-identity            # valida credenciais AWS
dbt debug                              # esperado: All checks passed!
```

## Erros comuns

### "Profile not found"
`profiles.yml` não está no projeto nem em `~/.dbt/`.
```bash
dbt debug --profiles-dir .
```

### "Cannot connect to Athena" / credenciais
```bash
aws configure
aws s3 ls s3://dataplatform-camara-dev-db/
```

### "S3 staging directory not found"
```bash
aws s3api put-object --bucket dataplatform-camara-dev-db --key athena-results/
```

### "Table not found" em uma source raw
A tabela ainda não foi criada no Glue:
```bash
dbt run-operation create_raw_tables --args '{select: votacoes__votacoes}'
```

### "Source sem colunas" / "sem data_type"
Toda tabela em `models/sources/raw.yml` precisa de `columns` com `data_type`. Gere um rascunho com `python scripts/infer_columns.py amostra.json`.

### Teste de frescor falhando
`assert_raw_votacoes_fresh` falha se a última partição tiver mais de 8 dias. Em dev isso é esperado quando não há ingestão recente.

## Validação final

```bash
dbt debug
dbt ls
dbt build --select stg_votacoes
```

## Estrutura de modelos

`models/camara/<assunto>/{staging,intermediate,marts}/`, com os 10 assuntos: blocos, deputados, eventos, frentes, grupos, legislaturas, orgaos, partidos, proposicoes, votacoes. Todos materializados como `table`.

```bash
dbt run --select tag:votacoes
dbt test --select tag:votacoes
```
