{% from 'filter.sql' import get_filter_statement %}

{%- set distinct_val_query -%}
select distinct {{ columns }}
from {{ source_table }}
{%- if filters is defined %}
where true AND
{{ get_filter_statement(filters) | indent }}
{%- endif %}
ORDER BY 1 desc 
limit 500
{%- endset -%}

{%- if columns is defined -%}
    {%- set results = run_query(distinct_val_query) -%}
    {%- if results is none -%}
        {{ raise_exception('Unable to successfully retrieve distinct values from your data warehouse.') }}
    {%- endif -%}
    {%- set distinct_vals = results[results.columns[0]].to_list() -%}
    {%- if distinct_vals is none -%}
        {{ raise_exception('0 distinct values met these conditions.') }}
    {%- endif -%}
{%- endif -%}

{%- if rows is defined -%}
    {%- set group_by = rows|join(', ') ~ ', '  -%}
{%- else -%}
    {%- set group_by = '' -%}
{%- endif -%}

WITH filtered as (
    SELECT *
    FROM {{ source_table }}
    {%- if filters is defined %}
    where true AND
    {{ get_filter_statement(filters) | indent }}
    {%- endif %}
)
{% if columns is defined %}
SELECT
    {{ group_by }}
{%- for this_val in distinct_vals -%}
{%- set ooloop = loop %}
{%- for column, aggs in values.items() %}
    {%- set oloop = loop %}
    {%- for aggregation_type in aggs %}
        {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}(
            {{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}
            case
            when {{ columns }} = '{{ this_val|replace("'", "\'") }}' then {{ column }}
            else null
            end
        )
            as {{ cleanse_name(this_val ~ '_' ~ aggregation_type ~ '_' ~ column)}}{{ ',' if not (loop.last and oloop.last and ooloop.last) }}
    {%- endfor %}
{%- endfor %}
{%- endfor %}
FROM filtered

{%- if rows is defined %}
GROUP BY {{ rows | join(', ') }}
{%- endif %}
{%- else %}

SELECT
    {{ group_by }}
    {%- for column, aggs in values.items() %}
        {%- set oloop = loop %}
        {%- for aggregation_type in aggs %}
            {{ aggregation_type|lower|replace('_', '')|replace('distinct', '') }}({{ 'distinct ' if 'distinct' in aggregation_type|lower else ''}}{{ column }}) as {{ cleanse_name(aggregation_type + '_' + column)}}{{ ',' if not (loop.last and oloop.last) }}
        {%- endfor %}
    {%- endfor %}
FROM filtered

{%- if rows is defined %}
GROUP BY {{ rows | join(', ') }}
{%- endif %}

ORDER BY
{%- for column, aggs in values.items() %}
    {%- set oloop = loop %}
    {%- for aggregation_type in aggs %}
{{ cleanse_name(aggregation_type + '_' + column)}} DESC {{ ',' if not (loop.last and oloop.last) }}
    {%- endfor %}
{%- endfor %}
NULLS LAST
{%- endif -%}