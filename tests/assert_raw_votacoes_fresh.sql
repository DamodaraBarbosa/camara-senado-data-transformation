-- Falha se a última partição da raw tiver mais de 8 dias (ou não existir)
select max(ingestion_date) as ultima_ingestao
from {{ source('raw', 'votacoes__votacoes') }}
having max(ingestion_date) is null
    or cast(date_parse(max(ingestion_date), '%Y-%m-%d') as date) < current_date - interval '8' day
