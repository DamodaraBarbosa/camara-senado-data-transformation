{% macro create_raw_tables(select=none, recreate=true) %}
  {% if execute %}
    {% set ns = namespace(count=0) %}
    {% for src in graph.sources.values() if src.source_name == 'raw' %}
      {% if select is none or src.name == select %}
        {% if not src.columns %}
          {{ exceptions.raise_compiler_error('Source sem colunas: ' ~ src.name) }}
        {% endif %}

        {% set parts = src.name.split('__') %}
        {% set location = 's3://' ~ raw_bucket() ~ '/raw/' ~ parts[0] ~ '/' ~ parts[1] ~ '/' %}
        {% set relation = '`' ~ src.schema ~ '`.`' ~ src.identifier ~ '`' %}

        {% set cols = [] %}
        {% for col in src.columns.values() %}
          {% if not col.data_type %}
            {{ exceptions.raise_compiler_error(src.name ~ '.' ~ col.name ~ ' sem data_type') }}
          {% endif %}
          {% do cols.append('`' ~ col.name ~ '` ' ~ col.data_type) %}
        {% endfor %}

        {% if recreate %}
          {% do run_query('DROP TABLE IF EXISTS ' ~ relation) %}
        {% endif %}

        {% set ddl %}
CREATE EXTERNAL TABLE IF NOT EXISTS {{ relation }} (
  {{ cols | join(',\n  ') }}
)
PARTITIONED BY (`ingestion_date` string)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION '{{ location }}'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.ingestion_date.type'='date',
  'projection.ingestion_date.format'='yyyy-MM-dd',
  'projection.ingestion_date.range'='{{ var("raw_start_date") }},NOW',
  'storage.location.template'='{{ location }}ingestion_date=${ingestion_date}/'
)
        {% endset %}

        {% do run_query(ddl) %}
        {% do log('tabela raw aplicada: ' ~ src.name, info=true) %}
        {% set ns.count = ns.count + 1 %}
      {% endif %}
    {% endfor %}
    {% if ns.count == 0 %}
      {{ exceptions.raise_compiler_error('Nenhuma source raw selecionada') }}
    {% endif %}
  {% endif %}
{% endmacro %}
