library(httr)
library(dplyr)
library(tidyverse)
library(sf)
library(tmap)
x <- GET("https://coronavirus.data.gov.uk/downloads/msoa_data/MSOAs_latest.csv")
bin <- content(x, "raw")
writeBin(bin, "data.csv")
dat = read.csv("data.csv", header = TRUE, dec = ",")

salisburyonly <- dplyr::filter(dat, str_detect(str_to_lower(areaName), "\\Salisbury"))
salisburyonly$date <- as.Date(salisburyonly$date)

today <- dplyr::filter(salisburyonly, date >= (Sys.Date()-7))
colnames(today)[which(names(today) == "areaCode")] <- "msoa11cd"

today$newCasesBySpecimenDateRollingSum <- as.integer(today$newCasesBySpecimenDateRollingSum)
today$newCasesBySpecimenDateRollingSum[is.na(today$newCasesBySpecimenDateRollingSum)] <- 0

today$newCasesBySpecimenDateRollingRate <- as.integer(today$newCasesBySpecimenDateRollingRate)
today$newCasesBySpecimenDateRollingRate[is.na(today$newCasesBySpecimenDateRollingRate)] <- 0

msoas <- st_read(dsn ="C:/Users/Danie/Desktop/MSOA2011/Middle_Layer_Super_Output_Areas__December_2011__Boundaries.shp")
msaossalis <- merge(msoas, today, by="msoa11cd")

tmap_mode("view")
tm_shape(msaossalis) +
  tm_polygons("newCasesBySpecimenDateRollingRate", id="areaName", palette = "-viridis", alpha=0.4, title = "Rolling Rate", breaks=c(0,10,50,100,200,400,1000)) +
  tm_basemap(leaflet::providers$CartoDB)