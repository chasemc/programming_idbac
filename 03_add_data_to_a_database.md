# Add Data to an IDBac Database


So, we've already seen how to connect to an existing IDBac database, and what an IDBac database consists of. In this section we'll learn how to add our own data to a new, or exisisting, IDBac database.


```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```



```r
library(here)
```

```
## here() starts at /home/chase/Downloads/tempo/programming_idbac
```



## Make a new empty IDBac database




We have five mzXML files in folder: `~data/mzxml`


```r
list.files(here::here("data", "mzxml"))
```

```
## [1] "172-1.mzXML"  "172-10.mzXML" "172-11.mzXML" "172-7.mzXML"  "Matrix.mzXML"
```



Create a new, empty, database named `my_new_database` in `~data/databases`

```r
IDBacApp::idbac_create(fileName = "my_new_database",
                       filePath = here::here("data",
                                             "databases"))
```

```
## [1] "/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite"
```

Connect to the new database

```r
db_connection <- IDBacApp::idbac_connect(fileName = "my_new_database",
                                         filePath = here::here("data",
                                                               "databases"))
```


It is indeed empty:


```r
dplyr::tbl(db_connection$my_new_database,
           "spectra")
```

```
## # Source:   table<spectra> [?? x 42]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
## # … with 42 variables: spectrum_mass_hash <chr>, spectrum_intensity_hash <chr>,
## #   xml_hash <chr>, strain_id <chr>, peak_matrix <blob>,
## #   spectrum_intensity <blob>, max_mass <int>, min_mass <int>, ignore <int>,
## #   number <int>, time_delay <int>, time_delta <dbl>,
## #   calibration_constants <chr>, v1_tof_calibration <chr>, data_type <chr>,
## #   data_system <chr>, spectrometer_type <chr>, inlet <chr>,
## #   ionization_mode <chr>, acquisition_method <chr>, acquisition_date <chr>, …
```



## Add data from an mzXML file


First let's add just a single xml file





```r
mz_file_paths <- IDBacApp:::find_mz_files(path = here::here("data", "mzxml"),
                                         recursive = FALSE,
                                         full = TRUE)
# only use one
mz_file_paths <- mz_file_paths[[1]]

print(mz_file_paths)
```

```
## [1] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/172-1.mzXML"
```

Get the name:

```r
mz_file_name <- base::basename(tools::file_path_sans_ext(mz_file_paths))

print(mz_file_name)
```

```
## [1] "172-1"
```



```r
mz_file_name <- base::basename(tools::file_path_sans_ext(mz_file_paths))



IDBacApp::db_from_mzml(mzFilePaths = here::here("data", "mzxml", paste0(mz_file_name, ".mzXML")),
                       sampleIds = mz_file_name,
                       idbacPool = db_connection$my_new_database,
                       acquisitionInfo = NULL)
```

```
## Processing in progress...
```

```
## Sample: 172-1; 1 of 1
```


Looking at what is contained within the database we see that four spectra were added to the table `spectra`.


```r
dplyr::tbl(db_connection$my_new_database, "spectra")
```

```
## # Source:   table<spectra> [?? x 42]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##   spectrum_mass_hash spectrum_intensity_hash xml_hash      strain_id peak_matrix
##   <chr>              <chr>                   <chr>         <chr>     <chr>      
## 1 03079d41f2615a86   45227279aa714a0b        54e5917cdcfd… 172-1     "{\"mass\"…
## 2 03079d41f2615a86   76b2b70f4504f720        54e5917cdcfd… 172-1     "{\"mass\"…
## 3 89f371168d2383ea   ab7792c742b93c9b        54e5917cdcfd… 172-1     "{\"mass\"…
## 4 89f371168d2383ea   a06916f1994389ae        54e5917cdcfd… 172-1     "{\"mass\"…
## # … with 37 more variables: spectrum_intensity <blob>, max_mass <int>,
## #   min_mass <int>, ignore <int>, number <int>, time_delay <int>,
## #   time_delta <dbl>, calibration_constants <chr>, v1_tof_calibration <chr>,
## #   data_type <chr>, data_system <chr>, spectrometer_type <chr>, inlet <chr>,
## #   ionization_mode <chr>, acquisition_method <chr>, acquisition_date <chr>,
## #   acquisition_mode <chr>, tof_mode <chr>, acquisition_operator_mode <chr>,
## #   laser_attenuation <int>, digitizer_type <chr>, …
```

One row was added in the table `metadata`.

```r
dplyr::tbl(db_connection$my_new_database, "metadata")
```

```
## # Source:   table<metadata> [?? x 20]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##   strain_id genbank_accession ncbi_taxid kingdom phylum class order family genus
##   <chr>     <chr>             <chr>      <chr>   <chr>  <chr> <chr> <chr>  <chr>
## 1 172-1     <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## # … with 11 more variables: species <chr>, maldi_matrix <chr>,
## #   dsm_cultivation_media <chr>, cultivation_temp_celsius <chr>,
## #   cultivation_time_days <chr>, cultivation_other <chr>,
## #   user_firstname_lastname <chr>, user_orcid <chr>,
## #   pi_firstname_lastname <chr>, pi_orcid <chr>, dna_16s <chr>
```

Two rows were added in the table `mass_index` (one for the reflectron spectra and one for the protein spectra).


```r
dplyr::tbl(db_connection$my_new_database, "mass_index")
```

```
## # Source:   table<mass_index> [?? x 2]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##   spectrum_mass_hash     mass_vector
##   <chr>                       <blob>
## 1 03079d41f2615a86   <raw 953.27 kB>
## 2 89f371168d2383ea   <raw 201.81 kB>
```

One row was added in the table `xml`. This contains the original mzXML file.

```r
dplyr::tbl(db_connection$my_new_database, "xml")
```

```
## # Source:   table<xml> [?? x 8]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##   xml_hash                   xml manufacturer model ionization analyzer detector
##   <chr>                   <blob> <chr>        <chr> <chr>      <chr>    <chr>   
## 1 54e5917cdcfdb755 <raw 5.11 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## # … with 1 more variable: instrument_metafile <chr>
```



## Adding multiple mzXML files

It is also possible to add multiple mzXML/mzML files at once, simply pass multiple paths and names as character vectors to `IDBacApp::db_from_mzml()`. 


```r
mz_file_paths <- IDBacApp:::find_mz_files(path = here::here("data", "mzxml"),
                                         recursive = FALSE,
                                         full = TRUE)
print(mz_file_paths)
```

```
## [1] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/172-1.mzXML" 
## [2] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/172-10.mzXML"
## [3] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/172-11.mzXML"
## [4] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/172-7.mzXML" 
## [5] "/home/chase/Downloads/tempo/programming_idbac/data/mzxml/Matrix.mzXML"
```

Names we will use:

```r
mz_file_names <- base::basename(tools::file_path_sans_ext(mz_file_paths))

print(mz_file_names)
```

```
## [1] "172-1"  "172-10" "172-11" "172-7"  "Matrix"
```



```r
IDBacApp::db_from_mzml(mzFilePaths = mz_file_paths,
                       sampleIds = mz_file_names,
                       idbacPool = db_connection$my_new_database,
                       acquisitionInfo = NULL)
```

```
## Processing in progress...
```

```
## Sample: 172-1; 1 of 5
```

```
## Processing in progress...
```

```
## Sample: 172-10; 2 of 5
```

```
## Processing in progress...
```

```
## Sample: 172-11; 3 of 5
```

```
## Processing in progress...
```

```
## Sample: 172-7; 4 of 5
```

```
## Processing in progress...
```

```
## Sample: Matrix; 5 of 5
```

```
## Warning in if (class(input) == "list") {: the condition has length > 1 and only
## the first element will be used
```

```
## Warning in if (class(input) == "matrix") {: the condition has length > 1 and
## only the first element will be used
```


We can see below that this has now added data for all of the mzXML files given.  

Important things to note:

1. The data from `172-1` was only added the first time. IDBac only appends data, it *never* overwrites data in the database (except in the metadata table). IDBac looks at each spectrum_mass_hash, spectrum_intensity_hash, and strain_id and only creates a new entry if those are unique from something already existing in the database.


```r
dplyr::tbl(db_connection$my_new_database,
           "spectra")
```

```
## # Source:   table<spectra> [?? x 42]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##    spectrum_mass_hash spectrum_intensity_hash xml_hash     strain_id peak_matrix
##    <chr>              <chr>                   <chr>        <chr>     <chr>      
##  1 03079d41f2615a86   45227279aa714a0b        54e5917cdcf… 172-1     "{\"mass\"…
##  2 03079d41f2615a86   76b2b70f4504f720        54e5917cdcf… 172-1     "{\"mass\"…
##  3 89f371168d2383ea   ab7792c742b93c9b        54e5917cdcf… 172-1     "{\"mass\"…
##  4 89f371168d2383ea   a06916f1994389ae        54e5917cdcf… 172-1     "{\"mass\"…
##  5 03079d41f2615a86   8a3cfc49f67e881c        81dd0a6c60f… 172-10    "{\"mass\"…
##  6 03079d41f2615a86   2a8e45c955c4f787        81dd0a6c60f… 172-10    "{\"mass\"…
##  7 89f371168d2383ea   0b51e06202aac501        81dd0a6c60f… 172-10    "{\"mass\"…
##  8 89f371168d2383ea   9e92eaf8e43765ef        81dd0a6c60f… 172-10    "{\"mass\"…
##  9 03079d41f2615a86   44999ed8b7c8dad4        8a497fd46f8… 172-11    "{\"mass\"…
## 10 03079d41f2615a86   159043e2317f12b7        8a497fd46f8… 172-11    "{\"mass\"…
## # … with more rows, and 37 more variables: spectrum_intensity <blob>,
## #   max_mass <int>, min_mass <int>, ignore <int>, number <int>,
## #   time_delay <int>, time_delta <dbl>, calibration_constants <chr>,
## #   v1_tof_calibration <chr>, data_type <chr>, data_system <chr>,
## #   spectrometer_type <chr>, inlet <chr>, ionization_mode <chr>,
## #   acquisition_method <chr>, acquisition_date <chr>, acquisition_mode <chr>,
## #   tof_mode <chr>, acquisition_operator_mode <chr>, laser_attenuation <int>, …
```


The `mass-index` table remains the same because in this case all the data had the same mass values across all protein and small molecule spectra.


```r
dplyr::tbl(db_connection$my_new_database,
           "mass_index")
```

```
## # Source:   table<mass_index> [?? x 2]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/databases/my_new_database.sqlite]
##   spectrum_mass_hash     mass_vector
##   <chr>                       <blob>
## 1 03079d41f2615a86   <raw 953.27 kB>
## 2 89f371168d2383ea   <raw 201.81 kB>
```
