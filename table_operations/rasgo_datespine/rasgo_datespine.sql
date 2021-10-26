with date_spine as (
    select
           row_number() over (order by null) as interval_id,
           dateadd(
               '{{ interval_type }}',
               {{ interval_amount}} * (interval_id - 1),
               '{{ start_timestamp }}'::timestamp_ntz) as ts_ntz_interval_start,
            dateadd(
               '{{ interval_type }}',
               {{ interval_amount}} * interval_id,
               '{{ start_timestamp }}'::timestamp_ntz) as ts_ntz_interval_end
from table (generator(rowcount => {{ count }}))
    )
select  {{ source_table }}.*,
  date_spine.interval_id as {{ date_col }}_interval_id,
  date_spine.ts_ntz_interval_start as {{ date_col }}_ts_ntz_interval_start,
  date_spine.ts_ntz_interval_end as {{ date_col }}_ts_ntz_interval_end
from {{ source_table }}
right outer join date_spine on
    {{ source_table }}.{{ date_col }} >= date_spine.ts_ntz_interval_start
    and
    {{ source_table }}.{{ date_col }} < date_spine.ts_ntz_interval_end