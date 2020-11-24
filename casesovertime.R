library(httr)
library(dplyr)
library(tidyverse)
library(sf)
library(tmap)
library(gifski)
library(stplanr)

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

#read in MSOA shapefile
msoas <- st_read(dsn ="C:/Users/Danie/Desktop/MSOA2011/Middle_Layer_Super_Output_Areas__December_2011__Boundaries.shp")
colnames(dat)[which(names(dat) == "areaCode")] <- "msoa11cd"

#filter data to salisbury only
sdat <- dplyr::filter(dat, str_detect(str_to_lower(areaName), "\\Salisbury"))

#construct salisbury msaos for mapping
saliscases <- merge(msoas, sdat, by="msoa11cd")

#load in centroids for labels
centroids_all <- pct::get_centroids_ew() %>% sf::st_transform(4326)

#combine centroids with salisbury data to produce salisbury labels
labelsalis <- merge(centroids_all, sdat, by="msoa11cd")
colnames(labelsalis)[which(names(labelsalis) == "areaName")] <- "Name"

anim = tmap_mode("plot") +
tm_shape(saliscases) +
  tm_polygons("newCasesBySpecimenDateRollingRate", id="areaName", palette = "-viridis", alpha=0.4, title = "Cases per 100,000 people", breaks=c(0,10,50,100,200,400,1000)) +
  tm_facets(along = "date", free.coords = FALSE) +
  tm_shape(labelsalis) + tm_text("Name") +
  tm_layout(title="7-Day Rate of COVID-19 Cases")

tmap_animation(tm=anim, filename = "anim2.gif", delay = 100)

