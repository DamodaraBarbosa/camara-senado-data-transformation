{{ config(
    materialized='view',
    tags=['staging', 'example']
) }}

-- Exemplo de staging model
-- Esta é uma view que faz transformações iniciais
SELECT
    1 as id,
    'exemplo' as nome
LIMIT 0  -- Remove todas as linhas, apenas para teste de sintaxe
