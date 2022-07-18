
# IDBac Databases Explained


Load necessary packages for this tutorial:

```r
library(IDBacApp)
# dplyr is for easily working with SQLite databases
library(dplyr)
# DBI is used to communicate with SQLite databases
library(DBI)
# pool manages SQLite database connections
library(pool)
```


First, download the example `idbac_experiment_file.sqlite` file.



Connect to the database



```r
example_pool <- IDBacApp::idbac_connect(fileName = "idbac_experiment_file",
                                        filePath = here::here("data",
                                                              "example_data"))
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

## Database Tables

IDBac has 6 tables which we'll go through one by one.


```r
cat(rev(DBI::dbListTables(example_pool)),
    sep = "\n")
```

```
## version
## spectra
## metaData
## mass_index
## locale
## XML
```


### The `Version` table

```r
dplyr::tbl(example_pool,
           "Version")
```

```
## # Source:   table<Version> [?? x 2]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##   idbac_version r_version                                                       
##   <chr>         <chr>                                                           
## 1 1.1.10        "{\"platform\":[\"x86_64-w64-mingw32\"],\"arch\":[\"x86_64\"],\…
```

This table contains two fields `IDBacVersion` and `rVersion`.

`IDBacVersion`  is the version of IDBac that was used to create the database
`rVersion` contains information on the version of R used to create the database. It is a JSON string and can be easily parsed using the `{JSONlite}` R package (among many others).


```r
a <- dplyr::tbl(example_pool,
           "version") %>% collect()

jsonlite::fromJSON(a$r_version)
```

```
## $platform
## [1] "x86_64-w64-mingw32"
## 
## $arch
## [1] "x86_64"
## 
## $os
## [1] "mingw32"
## 
## $system
## [1] "x86_64, mingw32"
## 
## $status
## [1] ""
## 
## $major
## [1] "3"
## 
## $minor
## [1] "6.0"
## 
## $year
## [1] "2019"
## 
## $month
## [1] "04"
## 
## $day
## [1] "26"
## 
## $`svn rev`
## [1] "76424"
## 
## $language
## [1] "R"
## 
## $version.string
## [1] "R version 3.6.0 (2019-04-26)"
## 
## $nickname
## [1] "Planting of a Tree"
```

There is also a helper function to get the IDBac/database version:

```r
IDBacApp::idbac_db_version(example_pool)
```

```
## [1] '1.1.10'
```





### The `locale` table

```r
dplyr::tbl(example_pool,
           "locale")
```

```
## # Source:   table<locale> [?? x 1]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##   locale                                                                        
##   <chr>                                                                         
## 1 LC_COLLATE=English_United States.1252;LC_CTYPE=English_United States.1252;LC_…
```

This table can be ignored. It stores the encodings used when creating the database. Its only real purpose is for debugging. 


### The `metadata` table

```r
dplyr::tbl(example_pool,
           "metadata")
```

```
## # Source:   table<metadata> [?? x 20]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##   strain_id genbank_accession ncbi_taxid kingdom phylum class order family genus
##   <chr>     <chr>             <chr>      <chr>   <chr>  <chr> <chr> <chr>  <chr>
## 1 172-1     <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## 2 172-10    <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## 3 172-11    <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## 4 172-7     <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## 5 Matrix    <NA>              <NA>       <NA>    <NA>   <NA>  <NA>  <NA>   <NA> 
## # … with 11 more variables: species <chr>, maldi_matrix <chr>,
## #   dsm_cultivation_media <chr>, cultivation_temp_celsius <chr>,
## #   cultivation_time_days <chr>, cultivation_other <chr>,
## #   user_firstname_lastname <chr>, user_orcid <chr>,
## #   pi_firstname_lastname <chr>, pi_orcid <chr>, dna_16s <chr>
```

This table starts out empty except for the field `Strain_ID`. It is to be filled in by the user, usually using the IDBac Shiny interface. It contains "extra" information about each sample.






### The `mass_index` table

```r
dplyr::tbl(example_pool,
           "mass_index")
```

```
## # Source:   table<mass_index> [?? x 2]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##   spectrum_mass_hash     mass_vector
##   <chr>                       <blob>
## 1 b83311689e011f6f   <raw 891.51 kB>
## 2 a30959c610fd9278   <raw 184.77 kB>
```


This is a good time to explain some (very) basic SQL and hashing, I will try to keep things simple and accessible. 

SQL is pretty cool because it allows you to structure your data to "hopefully" store things a minimum number of times. So we can store a data point once even if it relates to multiple other points- as long as we can reference this relationship. When retrieving results we merge mutliple tables together using these references and voila!

In the case of `mass_index` I noticed that, at least on the Bruker autoFlex instruments, all data collected using the same settings will contain the same exact `m/z` values for a mass spectrum. This means that, while we do have to store intensity values for every spectrum, we can potentially save space by only soring uniquee `m/z` vectors (the `massVector` field).


That brings us to the field `spectrumMassHash`. This is a short representation of the mass vectors that allows us to quickly reference a specfic mass vector as well as determine if a `massVector` is the same or different to a `massVector` already stored in the database. The importance of this will be more apparant later.





### The `xml` table

```r
dplyr::tbl(example_pool,
           "xml")
```

```
## # Source:   table<xml> [?? x 8]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##   xml_hash                   xml manufacturer model ionization analyzer detector
##   <chr>                   <blob> <chr>        <chr> <chr>      <chr>    <chr>   
## 1 ef1071a8faec5e1d <raw 2.49 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## 2 cd9f3314bdfda8ab <raw 2.38 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## 3 03d7c1f039677007 <raw 2.51 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## 4 3e7655edb05d19f8 <raw 2.48 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## 5 ddf801582cc6df94 <raw 1.03 MB> Bruker Dalt… Bruk… matrix-as… time-of… microch…
## # … with 1 more variable: instrument_metafile <chr>
```

The `xml` table stores the mzML (or mzxml of that was the input type) files and some basic information about the instrument if that information was available (e.g. information won't be present if spectra were converted from txt files). The `xml` field contains the compressed mzML/mzxml file, in full.



### The `spectra` table

```r
dplyr::tbl(example_pool,
           "spectra")
```

```
## # Source:   table<spectra> [?? x 42]
## # Database: sqlite 3.38.5
## #   [/home/chase/Downloads/tempo/programming_idbac/data/example_data/idbac_experiment_file.sqlite]
##    spectrum_mass_hash spectrum_intensity_hash xml_hash     strain_id peak_matrix
##    <chr>              <chr>                   <chr>        <chr>     <chr>      
##  1 b83311689e011f6f   6028ecf5d313b045        ef1071a8fae… 172-1     "{\"mass\"…
##  2 b83311689e011f6f   bac07d6e5744cf4e        ef1071a8fae… 172-1     "{\"mass\"…
##  3 a30959c610fd9278   b7238aee3626ef85        ef1071a8fae… 172-1     "{\"mass\"…
##  4 a30959c610fd9278   7ec32da4207c396a        ef1071a8fae… 172-1     "{\"mass\"…
##  5 b83311689e011f6f   60f61ee538773cda        cd9f3314bdf… 172-10    "{\"mass\"…
##  6 b83311689e011f6f   48f154a0e6d3a584        cd9f3314bdf… 172-10    "{\"mass\"…
##  7 a30959c610fd9278   5d8fc715f0478a5a        cd9f3314bdf… 172-10    "{\"mass\"…
##  8 a30959c610fd9278   95922f4f84fa25e7        cd9f3314bdf… 172-10    "{\"mass\"…
##  9 b83311689e011f6f   1f7851d0ae1debcf        03d7c1f0396… 172-11    "{\"mass\"…
## 10 b83311689e011f6f   502b1ed5bc032cd9        03d7c1f0396… 172-11    "{\"mass\"…
## # … with more rows, and 37 more variables: spectrum_intensity <blob>,
## #   max_mass <int>, min_mass <int>, ignore <int>, number <int>,
## #   time_delay <int>, time_delta <dbl>, calibration_constants <chr>,
## #   v1_tof_calibration <chr>, data_type <chr>, data_system <chr>,
## #   spectrometer_type <chr>, inlet <chr>, ionization_mode <chr>,
## #   acquisition_method <chr>, acquisition_date <chr>, acquisition_mode <chr>,
## #   tof_mode <chr>, acquisition_operator_mode <chr>, laser_attenuation <int>, …
```


And a full list of columns:


```r
a <- dplyr::tbl(example_pool,
           "spectra")

colnames(a)
```

```
##  [1] "spectrum_mass_hash"        "spectrum_intensity_hash"  
##  [3] "xml_hash"                  "strain_id"                
##  [5] "peak_matrix"               "spectrum_intensity"       
##  [7] "max_mass"                  "min_mass"                 
##  [9] "ignore"                    "number"                   
## [11] "time_delay"                "time_delta"               
## [13] "calibration_constants"     "v1_tof_calibration"       
## [15] "data_type"                 "data_system"              
## [17] "spectrometer_type"         "inlet"                    
## [19] "ionization_mode"           "acquisition_method"       
## [21] "acquisition_date"          "acquisition_mode"         
## [23] "tof_mode"                  "acquisition_operator_mode"
## [25] "laser_attenuation"         "digitizer_type"           
## [27] "flex_control_version"      "id"                       
## [29] "instrument"                "instrument_id"            
## [31] "instrument_type"           "mass_error"               
## [33] "laser_shots"               "patch"                    
## [35] "path"                      "laser_repetition"         
## [37] "spot"                      "spectrum_type"            
## [39] "target_count"              "target_id_string"         
## [41] "target_serial_number"      "target_type_number"
```

This is, inarguably, the most important table of the database. It is sample-level data (each row represents a single spectrum) and includes data like: `spectrumIntensity`, peak data `peakMatrix`, `maxMass`, `minMass`, etc.

The input for many of the fields (e.g. `massError`, `tofMode`) are extracted from Bruker's `acqus` files and so will only be present if you used IDBac to process Bruker raw data files directly.



## How do I use this????

Please see the other vignettes to see how make use of the databases. 







