a <- MALDIquant::createMassPeaks(mass = calibration_standard()$mass,
                            intensity = rep(1, 8))



z <- "C:/Users/CMC/Desktop/build/New folder.mzML"


z <- MALDIquantForeign::importMzMl(z)

z <- detectPeaks(z)

MALDIquant::determineWarpingFunctions()
