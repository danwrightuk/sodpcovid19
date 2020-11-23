library(httr)
library(dplyr)
library(tidyverse)
library(sf)
library(tmap)

#retrieve the data from the government's website
x <- GET("https://coronavirus.data.gov.uk/downloads/msoa_data/MSOAs_latest.csv")
bin <- content(x, "raw")
writeBin(bin, "data.csv")
dat = read.csv("data.csv", header = TRUE, dec = ",")

#merge data with lookup table
lookup = read.csv("C:/Users/Danie/Desktop/sodpcovid19/lookup.csv", header = TRUE, dec = ",")
colnames(lookup)[which(names(lookup) == "MSOA")] <- "areaCode"
dat <- merge(dat, lookup, by ="areaCode")

#convert R data formats and replace NA with 0
dat$newCasesBySpecimenDateRollingSum <- as.integer(dat$newCasesBySpecimenDateRollingSum)
dat$newCasesBySpecimenDateRollingSum[is.na(dat$newCasesBySpecimenDateRollingSum)] <- 0

dat$newCasesBySpecimenDateRollingRate <- as.integer(dat$newCasesBySpecimenDateRollingRate)
dat$newCasesBySpecimenDateRollingRate[is.na(dat$newCasesBySpecimenDateRollingRate)] <- 0

dat$date <- as.Date(dat$date)

#filter to cases within the last 7 days
last7days <- dplyr::filter(dat, date >= (Sys.Date()-7))

#read in MSOA shapefile and merge with case data
msoas <- st_read(dsn ="C:/Users/Danie/Desktop/MSOA2011/Middle_Layer_Super_Output_Areas__December_2011__Boundaries.shp")
colnames(last7days)[which(names(last7days) == "areaCode")] <- "msoa11cd"
mappable <- merge(msoas, last7days, by="msoa11cd")

#filter to only include Wilts MSOAs
wilts <- dplyr::filter(mappable, LTLA_areaName %in% c("Wiltshire"))

#filter to only include MSOAs with Salisbury in the name
salisbury <- dplyr::filter(mappable, str_detect(str_to_lower(areaName), "\\Salisbury"))

#enfield
enfield <- dplyr::filter(mappable, UTLA_areaName %in% c("Enfield"))

#plot a choropleth map of case data
tmap_mode("view")
tm_shape(salisbury) +
  tm_polygons("newCasesBySpecimenDateRollingRate", id="areaName", palette = "-viridis", alpha=0.4, title = "Rolling Rate", breaks=c(0,10,50,100,200,400,1000)) +
  tm_basemap(leaflet::providers$CartoDB)

tmap_mode("view")
tm_shape(wilts) +
  tm_polygons("newCasesBySpecimenDateRollingRate", id="areaName", palette = "-viridis", alpha=0.4, title = "Rolling Rate", breaks=c(0,10,50,100,200,400,1000)) +
  tm_basemap(leaflet::providers$CartoDB)

tmap_mode("view")
tm_shape(enfield) +
  tm_polygons("newCasesBySpecimenDateRollingRate", id="areaName", palette = "-viridis", alpha=0.4, title = "Rolling Rate", breaks=c(0,10,50,100,200,400,1000)) +
  tm_basemap(leaflet::providers$CartoDB)