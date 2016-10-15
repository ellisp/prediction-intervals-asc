# Does the example with the dodgy too-big prediction intervals taken from
# http://robjhyndman.com/hyndsight/forecast-combinations/

library(forecastHybrid)
library(ggplot2)
train <- window(co2, end = c(1990, 12))
test <- window(co2, start=c(1991, 1))
h <- length(test)
fit1 <- hybridModel(train, weights = "equal")
fc1 <- forecast(fit1, h=h)
p_dodgy <- autoplot(fc1) + 
  ggtitle("Forecast combination with prediction intervals that are too conservative") + 
  xlab("Year") +
  ylab(expression("Atmospheric concentration of CO"[2])) +
  labs(caption = "http://robjhyndman.com/hyndsight/forecast-combinations/")

svg("presentation/images/p_dodgy.svg", 8, 5)
print(p_dodgy)
dev.off()
