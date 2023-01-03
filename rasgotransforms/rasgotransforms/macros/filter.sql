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

    {% if 'columnName' in filter %}
        {% do filter.__setitem__('column_name', filter.columnName) %}
    {% endif %}
    {% if 'comparisonValue' in filter %}
        {% do filter.__setitem__('comparison_value', filter.comparisonValue) %}
    {% endif %}

    {% if filter.comparison_value is mapping %}
        {% if filter.comparison_value.type == 'RELATIVEDATE' or filter.comparison_value.type == 'relativedate' %}
            {% if 'datePart' in filter.comparison_value %}
                {% do filter.comparison_value.__setitem__('date_part', filter.datePart) %}
            {% endif %}
            {% if filter.comparison_value.direction == 'past' %}
                {% do filter.comparison_value.__setitem__('offset', -filter.comparison_value.offset)  %}
            {% endif %}
            {% if dw_type() == 'bigquery' %}
                {% do filter.__setitem__('comparison_value', "DATE_ADD(CURRENT_DATE, INTERVAL " ~ filter.comparison_value.offset ~ " " ~ filter.comparison_value.date_part ~ ")") %}
            {% elif dw_type() == 'snowflake' %}
                {% do filter.__setitem__('comparison_value', "DATEADD(" ~ filter.comparison_value.date_part ~ "," ~ filter.comparison_value.offset ~ ", CURRENT_DATE)") %}
            {% else %}
                {% do filter.__setitem__('comparison_value', "(CURRENT_DATE + INTERVAL '" ~ filter.comparison_value.offset ~ " " ~ filter.comparison_value.date_part ~ "')") %}
            {% endif %}
        {% endif %}
    {% endif %}

    {% if filter is not mapping %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter }}
    {% elif filter.operator|upper == 'CONTAINS' %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.column_name }} LIKE '%{{ filter.comparison_value }}%'
    {% else %}
    {{ logical_operator.value + ' ' if not loop.first }}{{ filter.column_name }} {{ filter.operator }} {{ filter.comparison_value }}
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
