source("analysis/helper-functions.R")


ds <- subset(tourism, "quarterly")

png("images/tourism-demo.png", width = 8000, height = 5000, res = 600)
par(bty = "l", family = "Calibri", mfrow = c(2, 2))
for(i in 13:16){
  dat <- ds[[i]]
  mod <- auto.arima(dat$x)
  fc <- forecast(mod, h = dat$h)
  plot(fc, main = paste("Tourism competition quarterly dataset", i))
  grid()
  lines(dat$xx, col = "red")
}
dev.off()
  
  ds[[1]]
