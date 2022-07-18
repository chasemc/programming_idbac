--- 
title: "Programming with IDBac"
author: "Chase Clark"
date: "2022-07-18"
#site: bookdown::bookdown_site
output: bookdown::pdf_book
documentclass: book
#bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
github-repo: chasemc/programmingidbac
description: "This contains some examples on how to program with IDBac; rather than, or complementing, using the Shiny app."
---

# Preamble

While some familiarity with R is suggested, the examples laid out within this book should be explantory enough for a novice to comfortable working through.

Suggestions or additions for content are welcome and may contributed at github.com/chasemc/programmingidbac Note that this project has a contributor covenenant TODO. 


## Major points:

Things you want to do will revolve around:

  - Creating an IDBac database from your raw (or converted) data
  - Moving data from one IDBac database to another
  - Accessing spectra 
  - Accessing peak-picked data
  - Filtering data by some attribute



## Download IDBac example file

The data used in this book uses example data that can be found here:
ftp://massive.ucsd.edu/MSV000084291


```r
library(here)
```

```
## here() starts at /home/chase/Downloads/tempo/programming_idbac
```

Let's download an IDBac experiment file (SQLite database).

```r
if (!file.exists(here::here("data",
                            "example_data",
                            "idbac_experiment_file.sqlite"))) {
  
  # Create a directory to download the example data to:
  dir.create(here::here("data"))
  dir.create(here::here("data",
                        "example_data"))
  # URL of example file
  ex_url <- "ftp://massive.ucsd.edu/MSV000084291/raw/data/idbac_experiment_file.sqlite"
  
  # Download example file ("wb" is important here)
  download.file(url = ex_url,
                destfile = here::here("data",
                                      "example_data",
                                      "idbac_experiment_file.sqlite"),
                mode = "wb")
}
```



This IDBac database is from one of the first versions of IDBac:


```r
example_pool <- IDBacApp::idbac_connect(fileName = "idbac_experiment_file",
                                        filePath = here::here("data",
                                                              "example_data"))
IDBacApp::idbac_db_version(example_pool$idbac_experiment_file)
```

```
## [1] '1.1.10'
```


We can update it as below:


```r
IDBacApp::idbac_update_db(example_pool$idbac_experiment_file)
```




