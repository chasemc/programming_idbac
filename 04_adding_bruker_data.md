# Starting With Bruker Data



Bruker data used in this chapter is available here:
https://massive.ucsd.edu/ProteoSAFe/dataset.jsp?task=7ce7c09a174545a4a7dfe80af25329b0



```r
library(here)
```

```
## here() starts at /home/chase/Downloads/tempo/programming_idbac
```



```r
bruker_data_path <- here::here("data",
                               "bruker_autoflex")
```


Data was acquired for both protein and small molecule data. Looking at the protein data we see that there is data from eight target spots (Spot C1, C10, etc):

```r
protein_path <- file.path(bruker_data_path,
                          "Protein_Data")

list.dirs(protein_path,
          recursive = FALSE,
          full.names = FALSE)
```

```
## [1] "0_C1"  "0_C10" "0_C11" "0_C7"  "0_D1"  "0_D10" "0_D11" "0_D7"
```





