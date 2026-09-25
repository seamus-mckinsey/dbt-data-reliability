{% macro create_table_like(relation, like_relation, temporary=False, like_columns=none) %}
    {% set empty_table_query %}
        SELECT
        {% if like_columns %}
            {% for column in like_columns %}
                {{ column }}{{ ", " if not loop.last }}
            {% endfor %}
        {% else %}
            *
        {% endif %}
        FROM {{ like_relation }}
        WHERE 1 = 0
    {% endset %}
    {% do elementary.create_or_replace(temporary, relation, empty_table_query) %}
{% endmacro %}
