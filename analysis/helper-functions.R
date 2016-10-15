theme_set(theme_light(base_family = "Calibri"))


#=============prediction interval functions===================
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
plot_cov <- function(res_df, hybridin = TRUE){
  names(res_df)[1:2] <- c("eighty", "ninetyfive")
  if(!hybridin){
    res_df <- filter(res_df, type != "Hybrid")
  }
  
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

#===========point interval functions============
# this is a reworked version of Tcomp::forecast_comp()
accuracy_point <- function (the_series, tests = list(the_series$h)) {
  x <- the_series$x
  xx <- the_series$xx
  h <- the_series$h
  mod1 <- hybridModel(x, models ="ae")
  fc1 <- forecast(mod1$auto.arima, h = h)
  fc2 <- forecast(mod1$ets, h = h)
  fc3 <- thetaf(x, h = h)
  fc4 <- snaive(x, h = h)
  fc5 <- forecast(mod1, h = h)
  
  
  MASEs <- matrix(0, nrow = 5, ncol = length(tests))
  for (j in 1:length(tests)) {
    this_test <- tests[[j]]
    MASEs[, j] <- c(accuracy(fc1, xx, test = this_test)["Test set", "MASE"], 
                    accuracy(fc2, xx, test = this_test)["Test set", "MASE"], 
                    accuracy(fc3, xx, test = this_test)["Test set", "MASE"], 
                    accuracy(fc4, xx, test = this_test)["Test set", "MASE"],
                    accuracy(fc5, xx, test = this_test)["Test set", "MASE"])                                                                                                                                                            
  }
  
  colnames(MASEs) <- gsub(":", "-", as.character(tests))
  rownames(MASEs) <- c("ARIMA", "ETS", "Theta", "Naive", "ARIMA-ETS average")
  return(MASEs)
}


#=========convenience============
summary.Mcomp <- function(dataobj){
  require(dplyr)
  require(tidyr)
  tmp <- as.data.frame(t(sapply(dataobj, function(x){
    return(c(x$type, x$period))
  })))
  
  names(tmp) <- c("Type", "Period")
  
  tmp <- tmp %>%
    group_by(Type, Period) %>%
    summarise(count = length(Type)) %>%
    spread(Type, count, fill = 0) %>%
    as.data.frame()
  
  return(tmp)
  
}

