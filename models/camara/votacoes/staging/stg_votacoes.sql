{{ config(materialized='table') }}

-- Cada ingestão é um snapshot completo: mantém apenas o arquivo mais recente
-- da partição mais recente. Table (não view): o Athena não aceita "$file_modified_time" em views.
with source as (
    select
        *,
        "$path" as _file_path,
        "$file_modified_time" as _file_modified_at
    from {{ source('raw', 'votacoes__votacoes') }}
),

latest_file as (
    select _file_path
    from source
    order by ingestion_date desc, _file_modified_at desc
    limit 1
)

select
    source.id as votacao_id,
    source.idorgao as orgao_id,
    source.siglaorgao as orgao_sigla,
    source.idevento as evento_id,
    source.data as data_votacao,
    source.datahoraregistro as data_hora_registro,
    source.aprovacao,
    source.descricao,
    source.votossim as votos_sim,
    source.votosnao as votos_nao,
    source.votosoutros as votos_outros,
    source.idlegislatura as legislatura_id,
    source.ultimaapresentacaoproposicao.descricao as ultima_apresentacao_descricao,
    source.ingestion_date,
    source._file_path
from source
inner join latest_file on source._file_path = latest_file._file_path
