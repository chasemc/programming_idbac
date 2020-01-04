a <-"F:/Chase/Projects/R01/data/raw_data/unzipped/2019_06_12_10745/Protein/0_A6"
a <- MALDIquantForeign::importBrukerFlex(a)



b <- IDBacApp::createFuzzyVector(massStart = 2000,
                          massEnd = 20000,
                          ppm = 1000,
                          massList = list(a[[1]]@mass),
                          intensityList = list(a[[1]]@intensity))
