{% macro create_or_replace(temporary, relation, sql_query) %}
    {{ return(adapter.dispatch('create_or_replace', 'elementary')(temporary, relation, sql_query)) }}
{% endmacro %}

{# Snowflake #}
{% macro default__create_or_replace(temporary, relation, sql_query) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
{% endmacro %}

{% macro bigquery__create_or_replace(temporary, relation, sql_query) %}
    {# Backport Elementary 0.26's hook-safe CTAS: dbt's macro requires a model context in v2. #}
    {% set create_query %}
        create or replace table {{ relation }}
        {% if temporary %}
            options (expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 1 hour))
        {% endif %}
        as {{ sql_query }}
    {% endset %}
    {% do elementary.run_query(create_query) %}
{% endmacro %}

{% macro redshift__create_or_replace(temporary, relation, sql_query) %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
    {% do adapter.commit() %}
{% endmacro %}

{% macro postgres__create_or_replace(temporary, relation, sql_query) %}
    {% do elementary.run_query("BEGIN") %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
    {% do elementary.run_query("COMMIT") %}
{% endmacro %}

{% macro spark__create_or_replace(temporary, relation, sql_query) %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
    {% do adapter.commit() %}
{% endmacro %}

{% macro athena__create_or_replace(temporary, relation, sql_query) %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
{% endmacro %}

{% macro trino__create_or_replace(temporary, relation, sql_query) %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
{% endmacro %}

{% macro clickhouse__create_or_replace(temporary, relation, sql_query) %}
    {% do dbt.drop_relation_if_exists(relation) %}
    {% do elementary.run_query(dbt.create_table_as(temporary, relation, sql_query)) %}
{% endmacro %}
