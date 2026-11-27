-- Falha se o snapshot mais recente tiver volume suspeito (cobertura parcial)
select count(*) as linhas
from {{ ref('stg_votacoes') }}
having count(*) < 1000
