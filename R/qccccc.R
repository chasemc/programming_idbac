
yep <- lapply(pp,
              function(x){

                pz <- x$int
                pz <- (pz / max(pz)) * 100
                #pz <- RcppRoll::roll_mean(pz, by = 500)
                a <- supsmu(1:length(pz), pz)
                pz[pz>6]

              })




pzz <- lapply(pp, function(x){

pz <- x$int
pz <- (pz / max(pz)) * 100
a <- supsmu(1:length(pz), pz)
pz <- pz - a$y

z <- RcppRoll::roll_max(pz, 400, fill=0, align = "center")

z <- split(z, factor(cut(1:length(z), 16, labels = F)))
sapply(z, max)
})

pzz2<-sapply(pzz, function(x) mean(x[c(-1, -2, -3)]) )



gb2 <- order(pzz2)


pgb <- pp[gb2]











