# p <- dplyr::tbl(con, "IndividualSpectra") %>%
#   filter(maxMass < 10000)
# p <- p %>% collect
#
# a <- p %>% filter(Strain_ID == "B-2706") %>% slice(8)
# z <- a$spectrumIntensity
#
# z <- IDBacApp::deserial(rawToChar(fst::decompress_fst(z[[1]])))
# plot(z, type="l")
