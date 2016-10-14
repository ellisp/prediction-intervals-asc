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

#=============helper functions===================
#' takes a forecast object, and the actual results, and returns a data frame
#' binary indicator of success as well as the horizon for each row and an optional
#' "type" column.
accuracy_pi <- function(fc, actual, type = NULL, labs = c("80%", "95%")){
  if(nrow(fc$upper) != length(actual)){
    stop("`fc` must be a forecast object with `upper` and `lower` objects that are matrices with number of rows equal to length of `actual`")
  }
  actual <- as.vector(actual)
  h <- length(actual)
  # take advantage of actual being a vector that will recycle, going down each
  # column of the two matrices of logical conditions we superimpose here:
  tmp <- as.data.frame(fc$lower < actual & fc$upper > actual)
  names(tmp) <- labs
  tmp <- cbind(tmp, 
               "h" = 1:h,
               "type" = rep(type, h))
  return(tmp)
}

#' takes a Mcomp or Tcomp object and tests the prediction interval coverage
#' of ets, auto.arima and hybrid models
coverage <- function(the_series, plot = FALSE){
 
  h <- the_series$h
  xx <- the_series$xx
  hm <- hybridModel(the_series$x, models = "ae")
  
  fc1 <- forecast(hm$ets, h = h)
  fc2 <- forecast(hm$auto.arima, h = h)
  fc3 <- forecast(hm, h = the_series$h)
  
  if(plot){
    par(mfrow = c(2, 2), bty = "l")
    plot(the_series, 
         main = str_wrap(the_series$description, 60), 
         ylab = the_series$sn)
    plot(fc1); lines(xx, col = "red")
    plot(fc2); lines(xx, col = "red")
    plot(fc3); lines(xx, col = "red")
    
  }
  
  res <- rbind(
    accuracy_pi(fc1, xx, "ETS"),
    accuracy_pi(fc2, xx, "ARIMA"),
    accuracy_pi(fc3, xx, "Hybrid")
  )
  res$sn <- the_series$sn
  res$period <- the_series$period
  return(res)
}


#' takes the results from coverage calculations on an entire data collection
#' (M3, M1 or Tourism) and produces a graphic summarising actual coverage
plot_cov <- function(res_df){
  names(res_df)[1:2] <- c("eighty", "ninetyfive")
  p <- res_df %>%
    group_by(h, period, type) %>%
    summarise(eighty = mean(eighty),
              ninetyfive = mean(ninetyfive)) %>%
    gather(confidence, value, -h, -period, -type) %>%
    mutate(confidence = gsub("eighty", "80%", confidence),
           confidence = gsub("ninetyfive", "95%", confidence)) %>%
    mutate(confidence = factor(confidence, levels = c("95%", "80%"))) %>%
    mutate(type = factor(type, levels = c("Hybrid", "ETS", "ARIMA"))) %>%
    mutate(desiredlevel = ifelse(confidence == "80%", 0.8, 0.95)) %>%
    ggplot(aes(x = h, y = value, colour = type)) +
    facet_grid(confidence ~ period, scales = "free_x") +
    geom_line(aes(y = desiredlevel), colour = "black") +
    geom_line(size = 1.2) +
    scale_y_continuous("Actual empirical coverage of prediction interval", label = percent) +
    scale_colour_brewer("Model", palette = "Set1") +
    labs(x = "Forecast horizon")
  return(p)
}


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
