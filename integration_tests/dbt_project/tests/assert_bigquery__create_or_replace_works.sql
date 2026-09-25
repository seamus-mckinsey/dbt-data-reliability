{{ config(enabled=target.type == 'bigquery') }}

{% if execute %}
    {% set relation = api.Relation.create(
        database=target.database,
        schema=target.schema,
        identifier='edr_ctas_' ~ invocation_id | replace('-', ''),
        type='table'
    ) %}
    {% do adapter.create_schema(api.Relation.create(database=target.database, schema=target.schema)) %}
    {% do elementary.create_or_replace(true, relation, 'SELECT 1 AS old_value') %}
    {% do elementary.create_or_replace(true, relation, 'SELECT 2 AS new_value') %}
    {% set result = run_query('SELECT COUNT(*) AS row_count, MAX(new_value) AS value FROM ' ~ relation) %}
    {% set options_query %}
        SELECT COUNT(*) AS expiry_count
        FROM `{{ target.database }}.{{ target.schema }}.INFORMATION_SCHEMA.TABLE_OPTIONS`
        WHERE table_name = '{{ relation.identifier }}'
            AND option_name = 'expiration_timestamp'
    {% endset %}
    {% set options = run_query(options_query) %}
    {% do adapter.drop_relation(relation) %}

    SELECT 1 AS failure
    FROM (SELECT 1) AS assertion_row
    WHERE {{ result.rows[0][0] }} != 1
        OR {{ result.rows[0][1] }} != 2
        OR {{ options.rows[0][0] }} != 1
{% else %}
    SELECT 1 AS failure FROM (SELECT 1) AS assertion_row WHERE 1 = 0
{% endif %}
