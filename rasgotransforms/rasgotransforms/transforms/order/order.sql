SELECT *
FROM {{source_table}}
ORDER BY
{% if column_order is defined %}
    {%- for col_name in column_order %}
        {{ col_name }} {{ order_by[col_name] }}{{ ',' if not loop.last else ' ' }}
    {%- endfor -%}
{% else %}
    {%- for col, order_method in order_by.items() %}
        {{ col }} {{ order_method }}{{ ',' if not loop.last else ' ' }}
    {%- endfor -%}
{% endif %}

