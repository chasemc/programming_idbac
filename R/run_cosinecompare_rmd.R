



createReport <- function(report_dir,
                         sql_name,
                         sql_dir){

  rmd <- "C:/Users/CMC/Documents/GitHub/programmingIDBac/Cosine_compare.Rmd"
  rmarkdown::render(rmd,
                    params = list(sql_name = sql_name,
                                  sql_dir = sql_dir),
                    output_file = file.path(report_dir, paste0(sql_name, ".html")))
}




path <- "C:/Users/CMC/downloads"

sql_dbs <- list.files(path, full.names = F, pattern = "20190610.sqlite")

sql_dbs <- tools::file_path_sans_ext(sql_dbs)




for (i in seq_along(sql_dbs)) {

createReport(report_dir = "C:/Users/CMC/IDBac_experiments",
             sql_name = sql_dbs[[i]],
             sql_dir = path)
}
