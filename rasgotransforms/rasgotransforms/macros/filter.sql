{% macro get_filter_statement(filters) %}
{% if filters %}
{% if filters is string %}
{{ filters }}
{% else %}
{% set logical_operator = namespace(value='AND') %}
{% for filter in filters %}
    {% if filter is not string %}
        {% if filter is not mapping %}
            {% set filter = dict(filter) %}
        {% endif %}
        {% if filter is mapping and 'compoundBoolean' in filter and filter['compoundBoolean'] %}
            {% set logical_operator.value = filter['compoundBoolean'] %}
        {% endif %}
    {% endif %}
{% endfor %}
(
    {% for filter in filters %}
    {% if filter is not string and filter is not mapping %}
    {% set filter = dict(filter) %}
    {% endif %}
    {% if 'column_name' in filter %}
        {% do filter.__setitem__('columnName', filter.column_name) %}
    {% endif %}
    {% if 'comparison_value' in filter %}
        {% do filter.__setitem__('comparisonValue', filter.comparison_value) %}
    {% endif %}
    {% if filter is not mapping %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.columnName }} like '%{{ filter.comparisonValue }}%'
    {% else %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.columnName }} {{ filter.operator }} {{ filter.comparisonValue }}
    {% endif %}
    {% endfor %}
)
{% endif %}
{% else %}
true
{% endif %}
{% endmacro %}


{% macro combine_filters(filters_a, filters_b, condition) %}
{% set condition = condition if condition is defined else 'AND' %}
{% if filters_a and not filters_b %}
{{ get_filter_statement(filters_a) }}
{% elif filters_b and not filters_a %}
{{ get_filter_statement(filters_b) }}
{% elif not filters_a and not filters_b %}
true
{% else %}
(
    {{ get_filter_statement(filters_a)|indent }}
    {{ condition }}
    {{ get_filter_statement(filters_b)|indent }}
)
{% endif %}
{% endmacro %}
