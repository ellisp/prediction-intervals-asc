library(knitr)
library(rmarkdown)
library(ggplot2)
library(scales)
library(Tcomp)
library(Mcomp)
library(forecast)
library(extrafont)

# Notes.  This isn't fully reproducible end to end but isn't worth polishing up completely.
# One of the images comes from a blog post, see http://ellisp.github.io
# Some of the images generated in the code below are SVGs and need to be converted to PNG (I did this with ImageMagick)

source("analysis/helper-functions.R")
source("analysis/dodgy-pi.R")
source("analysis/prediction-intervals-coverage.R") # takes 20+ minutes to run.  Could be parallelised
source("analysis/point-accuracy.R")
source("ad-hoc-powerpoint.R")
source("ensemble-ets-aa-naive-nnetar.R")
# rendering the presentation easiest done with the knit button