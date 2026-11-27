{{ config(
    materialized='view',
    tags=['staging', 'votacoes']
) }}

-- Exemplo de staging model para votações
-- Esta view faz transformações iniciais dos dados brutos
-- Recomendação: Adapte este arquivo com suas transformações reais

SELECT
    id_votacao,
    id_deputado,
    data_votacao,
    voto
FROM {{ source('raw_camara', 'votacoes') }}
LIMIT 0  -- Remove todas as linhas, apenas para teste de sintaxe
