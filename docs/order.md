

# order

Order a dataset by specified columns, in a specified order

## Parameters

|     Name     |       Type        |                                      Description                                       | Is Optional |
| ------------ | ----------------- | -------------------------------------------------------------------------------------- | ----------- |
| order_by     | column_value_dict | dict where the keys are column names and the values are the order_method (ASC or DESC) |             |
| column_order | column_list       | order of the columns for the order by                                                  |             |


## Example

```python
ds = rasgo.get.dataset(id)

ds2 = ds.order(order_by={'DS_WEATHER_ICON':'ASC', 'DS_DAILY_HIGH_TEMP':'DESC'})
ds2.preview()
```

## Source Code

{% embed url="https://github.com/rasgointelligence/RasgoTransforms/blob/main/rasgotransforms/rasgotransforms/transforms/order/order.sql" %}

