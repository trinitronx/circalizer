#!/usr/bin/env python3

import dask.dataframe as dd
df = dd.read_csv('data/sleep.csv', parse_dates=['Sleep Start Local', 'Sleep End Local'])

#df.head()
df.to_parquet('data/sleep_2018-21.parquet', engine='pyarrow')
