# independentStudyGolfAnalytics
My independent study for my Masters of Science in Business Analytics, under the advisement of Dr. Tim Urban.

# Main.csv
Round-by-round scores for a select group of professional golfers in a select group of tournaments from the 2015 through the 2018 PGA Tour seasons.

Golfer: Name of golfer that played the round

Event: Name of event the round way played in

Year: Year of event

Round: Round number (1 through 4)

Score: Score of the round, relative to par

Location: City that the round was played in

Date: Date that the round was played

# RoundWeather.csv
Round-by-round weather data for all rounds played in the Main.csv.

Location: City that the round was played in

Date: Date that the roudn was played

RAltitude: Altitude that the round was played at, as a proxy for air density, measured in feet

RTemp: High temperature for the date and location that the round was played

RWind: Speed of the wind for the date and location that the round was played

RPrecip: A binary variable, 1 if rainy, 0 if not (not used in analysis, a dirty variable)

RHumid: Humidity for the date and location that the eround was played

# Hometowns.csv
Historical climate averages for the hometowns of the golfers used in this analysis.

Golfer: Name of the golfer

Hometown: Name of the golfer's hometowns

State/Region: State or region of the golfer's hometown

Country: Home country of the golfer

Websites: Source of historical climate data used for that golfer's hometown (sometimes a close proxy was used for obscure towns that had insufficient records)

Elevation: Elevation of the town, as a proxy for air density

MonthWeatherFactor: The historical average of some weather factor for some month, i.e. MayWind is the average daily wind speed for the month of May

# FinleyAndHalsey.csv
A table of a select group of season average performance statistics for a select group of professional golfers. The performance statistics were chosen because of their inclusion in the Finley and Halsey model for predicting golf scores. The data was obtained from the PGA Tour website, which goes into further detail in how the statistics are calculated, as it is not always the most intuitive representation.

Name: Name of golfer

Season: Season of golfer's performance

DrivingDist: Average driving distance of the golfer for that season, measured in yards

DrivingAcc: Average driving accuracy of the golfer for that season, measured in percentage

GIR: Average greens in regulation of the golfer for that season, measured in percentage

SandSaves: Average sand saves of the golfer for that season, measured in percentage

Putts: Average number of putts per round of the golfer for that season

Events: Number of events the golfer played that season

# GolfAnalytics.R
The R code of my data cleansing, wrangling, and regression analysis.

# Report.docx
The full report that outlines my analysis in detail, with visualizations and key metrics.
