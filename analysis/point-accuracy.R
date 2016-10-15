library(Tcomp)
library(forecastHybrid)
library(tidyr)
library(dplyr)
library(english)


source("analysis/helper-functions.R")

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
clusterExport(cluster, "accuracy_point")


#-----------------M1----------------------
results_point <- parLapply(cluster,
                       subset(M3, "quarterly"),
                       accuracy_point,
                       tests = list(2, 4, 6, 8))

results_point_df <- as.data.frame(do.call("rbind", results_point))
results_point_df$model <- row.names(results_point_df)
results_point_df <- results_point_df %>%
  gather(horizon, MASE, -model) %>%
  group_by(model, horizon) %>%
  summarise(MASE = round(mean(MASE), 2)) %>%
  mutate(horizon = factor(english(as.numeric(horizon)), levels = c("two", "four", "six", "eight"))) %>%
  spread(horizon, MASE) %>%
  arrange(eight) 

save(results_point_df, file = "presentation/data/results_point_df.rda")


stopCluster(cluster)
