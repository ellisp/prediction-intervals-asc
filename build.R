library(knitr)
library(rmarkdown)

source("analysis/helper-functions.R")
source("analysis/dodgy-pi.R")
source("analysis/prediction-intervals-coverage.R") # takes 20+ minutes to run
source("analysis/point-accuracy.R")

# rendering the presentation easiest done with the knit button