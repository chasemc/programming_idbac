# Connect to an IDBac Database


Load the necessary packages for this tutorial:

```r
library(IDBacApp)
```



## Connect to IDBac database

Here we will make a connection to the database. 

Under the hood IDBac uses the `{pool}` package and some IDBac functions expect a `pool` object and thus it is the preferred way to handle IDBac databases from within R.



```r
example_pool <- IDBacApp::idbac_connect(fileName = "idbac_experiment_file",
                                        filePath = here::here("data",
                                                              "example_data"))
```


Notice that this isn't a pool object, it's a list (this is for a reason- it helps the IDBac Shiny app make multiple connections).


```r
class(example_pool)
```

```
## [1] "list"
```

To get our pool object let's pull it out of the list.

```r
# example_pool$idbac_experiment_file would also work 
example_pool <- example_pool[[1]]
class(example_pool)
```

```
## [1] "Pool" "R6"
```

You should now be connected to an IDBac experiment/database!