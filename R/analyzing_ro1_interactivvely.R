library(dplyr)
a <- "F:/Chase/Projects/R01/data"
b <- IDBacApp::createPool("bigGuy",
                          a)[[1]]

b %>%
  tbl("IndividualSpectra") %>%
  pull(Strain_ID) ->p






b %>%
  tbl("IndividualSpectra") %>%
 # filter(Strain_ID == "BS3610") %>%
  filter(maxMass > 10000) %>%
#  filter(number  < 41980) %>%
pull(spectrumIntensity) -> p


result <- lapply(p,
                 function(x){
                   IDBacApp::deserial(rawToChar(fst::decompress_fst(x)))
                 })
rt <- do.call(cbind, result)
rt <- coop::cosine(rt)
plot(hclust(as.dist(1-rt)))


meas <- 1-rt

meas <- as.data.frame(meas)




plot(meas)
text(meas)
abline(h=mean(meas))
abline(h=(1*sd(meas) + mean(meas)), col="blue")
abline(h=(2*sd(meas) + mean(meas)), col="green")
abline(h=(3*sd(meas) + mean(meas)), col="red")

