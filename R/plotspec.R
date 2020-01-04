#
# tbl(just_one_con, "IndividualSpectra") %>%
#   filter(maxMass < 10000) %>%
#   select(c("Strain_ID","spectrumIntensity")) %>%
#   collect() %>%
#   return(.) -> p
# p %>%  filter(Strain_ID == "D030") ->p
#
#
# result <- lapply(1:nrow(p),
#                  function(x){
#                    IDBacApp::deserial(rawToChar(fst::decompress_fst(p[x, 2][[1]][[1]])))
#                    })
#
# for(i in seq_along(result)){
#   png(paste0(i, ".png"))
#   plot(result[[i]], type = "l")
#
#   dev.off()
# }
