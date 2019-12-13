library(lubridate)
library(dplyr)
library(olsrr)

setwd(paste(getwd(),"/Independent Study/", sep=""))

#read files
hometowns <- read.csv("Hometowns.csv")
rounds <- read.csv("RoundWeather.csv")
main <- read.csv("Main.csv")
fh <- read.csv("FinleyAndHalsey.csv")

#clean hometowns up
hometowns<-hometowns[which(hometowns$Golfer!=""),]
# hometowns[,grepl("Temp", colnames(hometowns))]

#clean Main up
#remove any records with null Golfers
main <- main[which(main$Golfer != ""),]

#retype the Date column
main$Date <- as.character(main$Date)

#get the month of the rounds in order to compare to "historical" months
main$Month <- month(mdy(main$Date))

#organize rounds into their perspective PGA Tour seasons
main$Season <- main$Year
main$Season[main$Month<9] <- main$Year[main$Month<9]-1
main <- main[,colSums(is.na(main))<nrow(main)]

#remove any null records from fh by removing rows with null Names
fh <- fh[which(fh$Name != ""),]

#add id column that combines first and last names
fh$id <- gsub(" ","",paste(fh$Name,fh$Season))
main$id <- gsub(" ","",paste(main$Golfer,main$Year))

#join the performance statistics to the golfers and their locations
main <- left_join(main, fh[,3:9], by = "id")

months <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

#weather breakdowns
#these lines of code select the histories specific to each climate statistic
#so hTemps becomes just the hometown temperature history
hTemps <- cbind(hometowns[,c("Golfer", grep("Temp", names(hometowns),value=TRUE))])
hRains <- cbind(hometowns[,c("Golfer", grep("Rain", names(hometowns),value=TRUE))])
hHumids <- cbind(hometowns[,c("Golfer", grep("Humid", names(hometowns),value=TRUE))])
hWinds <- cbind(hometowns[,c("Golfer", grep("Wind", names(hometowns),value=TRUE))])

#bring in round weather to the mainframe
main <- left_join(main, rounds, by = c("Location", "Date"))

#bring in hometown weather to the main dataframe
#rain
main <- left_join(main, hRains, by = "Golfer")
for (row in 1:nrow(main)){
  main[row,"HRain"] <- main[row,main[row,"Month"]-12+ncol(main)]
}
main <- main[,!names(main) %in% names(hRains)[2:ncol(hRains)]]

#humidity
main <- left_join(main, hHumids, by = "Golfer")
for (row in 1:nrow(main)){
  main[row,"HHumid"] <- main[row,main[row,"Month"]-12+ncol(main)]
}
main <- main[,!names(main) %in% names(hHumids)[2:ncol(hHumids)]]

#temp
main <- left_join(main, hTemps, by = "Golfer")
for (row in 1:nrow(main)){
  main[row,"HTemp"] <- main[row,main[row,"Month"]-12+ncol(main)]
}
main <- main[,!names(main) %in% names(hTemps)[2:ncol(hTemps)]]

#wind
main <- left_join(main, hWinds, by = "Golfer")
for (row in 1:nrow(main)){
  main[row,"HWind"] <- main[row,main[row,"Month"]-12+ncol(main)]
}
main <- main[,!names(main) %in% names(hWinds)[2:ncol(hWinds)]]

#elevation
main <- left_join(main, hometowns[,c("Golfer", "Elevation")], by = "Golfer")
for (row in 1:nrow(main)){
  main[row,"HElev"] <- main[row,"Elevation"]
}
main <- main[,!names(main) %in% "Elevation"]

#create the deltas
main$deltaRain <- abs(scale(main$HRain - main$RPrecip))
main$deltaTemp <- abs(scale(main$HTemp - main$RTemp))
main$deltaHumid <- abs(scale(main$HHumid - main$RHumid))
main$deltaWind <- abs(scale(main$HWind - main$RWind))
main$deltaElev <- abs(scale(main$HElev - main$RAltitude))

#form the new dataframe
main2 <- main[,c("id",names(fh)[3:7], "Score", "deltaRain", "deltaTemp", "deltaHumid", "deltaWind", "deltaElev")]

#aggregate
main2 <- aggregate(main2[,2:ncol(main2)], list(main2$id), mean)

#weather metric
main2$weather <- rowMeans(main2[,(ncol(main2)-3):ncol(main2)])

#regression
noWeatherModel <- lm(Score ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts , data = main2)
weatherModel <- lm(Score ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts + weather, data = main2)

summary(noWeatherModel)
summary(weatherModel)

main2$weatherSq <- main2$weather**2

#build the model again with a squared weather factor
weatherSqModel <- lm(Score ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts + weatherSq, data = main2)

summary(weatherSqModel)

weatherBroken <- lm(Score ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts + deltaTemp + deltaHumid + deltaWind + deltaElev, data = main2)

summary(weatherBroken)

weather2 <- lm(Score*weather ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts, data = main2)

summary(weather2)

#outlier study

cooksd <- cooks.distance(weatherBroken)
plot(cooksd, pch="*", cex=2, main="Influential Obs by Cooks distance")  # plot cook's distance
abline(h = 4*mean(cooksd, na.rm=T), col="red")  # add cutoff line
text(x=1:length(cooksd)+1, y=cooksd, labels=ifelse(cooksd>4*mean(cooksd, na.rm=T),names(cooksd),""), col="red")  # add labels
influential <- as.numeric(names(cooksd)[(cooksd > 4*mean(cooksd, na.rm=T))])  # influential row numbers

main2[influential,"Score"] <- mean(main2[-influential,"Score"])

#stepwise variable selection
varsel <- ols_step_all_possible(weatherBroken)
bestsub <- ols_step_best_subset(weatherBroken)

varsel[382,]

weatherBroken <- lm(Score ~ DrivingDist + DrivingAcc + GIR + SandSaves + Putts + deltaTemp, data = main2)

par(mfrow = c(2, 2))
plot(weatherBroken)

ols_vif_tol(weatherBroken)

summary(weatherBroken)
