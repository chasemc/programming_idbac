
library(ggplot2)



working_directory <- "C:/Users/chase/Downloads/temp"
#
# # URL of example file
# ex_url <- "ftp://massive.ucsd.edu/MSV000084291/raw/data/idbac_experiment_file.sqlite"
# # Path of created file
# ex_path <- normalizePath(file.path(working_directory,
#                                    "idbac_experiment_file.sqlite"),
#                          winslash = "/",
#                          mustWork = FALSE)
# # Download example file ("wb" is important here)
# download.file(url = ex_url,
#               destfile = ex_path,
#               mode = "wb")

example_pool <- IDBacApp::createPool(fileName = "idbac_experiment_file",
                                     filePath = working_directory)[[1]]





a <- IDBacApp::mquantSpecFromSQL(pool = example_pool,
                                 sampleID = "172-1",
                                 protein = T,
                                 smallmol = FALSE)



ave_spec <- MALDIquant::averageMassSpectra(a)


C:\\Users\\chase\\DesktopDownloads\SpinWorksJ_20170824

approx_spec <- function(x, y=NULL, method="linear", yleft, yright,
                        rule=1L,  f=0L, ties=mean) {
  if (isEmpty(x)) {
    function(x)rep.int(NA, length(x))
  } else {
    approx(x=x@mass, y=x@intensity, method=method,
              yleft=yleft, yright=yright, rule=rule, f=f, ties=ties)
  }
}




## interpolate not existing masses
approxSpectra <- lapply(a, approx_spec)

## get interpolated intensities
intensityList <- lapply(approxSpectra, function(x)x(ave_spec@mass))

## create a matrix which could merged
m <- do.call(rbind, intensityList)

## merge intensities
intensity <- fun(m, na.rm=TRUE)
## merge intensities
intensity <- fun(m, na.rm=TRUE)





for (i in seq_along(a)) {

  a[[i]]@mass <- lin_ext(a[[i]]@mass)
}


b <- cbind.data.frame(mass = a[[1]]@mass,
                      intensity = a[[1]]@intensity)




ggplot(b, aes(x = mass,
              y = intensity)) +
  geom_line()





approxfun(x=x@mass, y=x@intensity, method="linear",
          yleft=0L, yright=0L, rule=1L, f=0L, ties=mean)
