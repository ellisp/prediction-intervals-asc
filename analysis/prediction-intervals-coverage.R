library(Mcomp)
library(Tcomp)
library(forecastHybrid)
library(parallel)
library(dplyr)
library(tidyr)
library(scales)
library(ggplot2)
library(extrafont)
library(Cairo)
library(grid)
library(stringr)
library(ggthemes)

theme_set(theme_light(base_family = "Calibri"))

source("analysis/helper-functions.R")

#============trial runs===================
coverage(M1[[59]], plot = TRUE)
coverage(M3[[2000]], plot = TRUE)
coverage(M1[[450]], plot = TRUE)
coverage(tourism$M13, plot = TRUE)

smallM3 <- list(M3[[1]], M3[[500]])

lapply(smallM3, coverage)


#==============run for real, in parallel, on 3 big data collections============
#------------Set up multi core cluster----------------
# set up cluster with number of cores minus one
cores <- detectCores()
cluster <- makePSOCKcluster(max(1, cores - 1))

# set up the functionality on the cluster
clusterEvalQ(cluster, {
  library(Tcomp)
  library(Mcomp) 
  library(forecastHybrid)
})
clusterExport(cluster, "accuracy_pi")


#-----------------M1----------------------
M1results <- parLapply(cluster,
                     M1,
                     coverage)

M1results_df <- do.call("rbind", M1results)
names(M1results_df)[1:2] <- c("eighty", "ninetyfive")

plot_cov(M1results_df) +
  ggtitle("Poor prediction interval coverage in the M1 competition")

# worst results?
zeroes <- M1results_df %>%
  group_by(sn) %>%
  summarise(ninetyfive = mean(ninetyfive),
            eighty = mean(eighty)) %>%
  filter(eighty == 0)
  
CairoPDF("BadPredictionsM1.pdf", 11, 8)
for(i in 1:nrow(zeroes)){
  par(family = "Calibri")
  the_series <- M1[[zeroes[i, ]$sn]]
  quiet <- coverage(the_series, plot = TRUE)
}
dev.off()



#---------------------------M3---------------------
M3results <- parLapply(cluster,
                       M3,
                       coverage)

M3results_df <- do.call("rbind", M3results)
names(M3results_df)[1:2] <- c("eighty", "ninetyfive")

plot_cov(M3results_df) +
  ggtitle("Prediction intervals in the M3 competition")

#---------------tourism-------------------------
Tresults <- parLapply(cluster,
                       tourism,
                       coverage)

Tresults_df <- do.call("rbind", Tresults)
names(Tresults_df)[1:2] <- c("eighty", "ninetyfive")

plot_cov(Tresults_df) +
  ggtitle("Prediction intervals performed well in the tourism competition")

# worst results?
zeroes <- Tresults_df %>%
  group_by(sn) %>%
  summarise(ninetyfive = mean(ninetyfive),
            eighty = mean(eighty)) %>%
  filter(eighty == 0)

CairoPDF("BadPredictionsT.pdf", 11, 8)
for(i in 1:nrow(zeroes)){
  par(family = "Calibri")
  the_series <- tourism[[zeroes[i, ]$sn]]
  quiet <- coverage(the_series, plot = TRUE)
}
dev.off()


stopCluster(cluster)
