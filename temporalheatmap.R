library(httr)
library(data.table)  
library(dplyr)       
library(purrr)      
library(tidyr)       
library(ggplot2)     
library(scales)      
library(gridExtra)  
library(viridis)    
library(knitr)
library(tidyverse)
library(plotly)

#retrieve the data from the government's website
x <- GET("https://coronavirus.data.gov.uk/downloads/msoa_data/MSOAs_latest.csv")
bin <- content(x, "raw")
writeBin(bin, "data.csv")
dat = read.csv("data.csv", header = TRUE, dec = ",")

#convert R data formats and replace NA with 0
dat$newCasesBySpecimenDateRollingSum <- as.integer(dat$newCasesBySpecimenDateRollingSum)
dat$newCasesBySpecimenDateRollingSum[is.na(dat$newCasesBySpecimenDateRollingSum)] <- 0

dat$newCasesBySpecimenDateRollingRate <- as.integer(dat$newCasesBySpecimenDateRollingRate)
dat$newCasesBySpecimenDateRollingRate[is.na(dat$newCasesBySpecimenDateRollingRate)] <- 0

dat$date <- as.Date(dat$date)

sdat <- dplyr::filter(dat, str_detect(areaName, "\\Salisbury|\\Laverstock|Wilton, Nadder & Ebble|\\Great Wishford|\\Downton|Amesbury|Durrington & Bulford|Whaddon, Whiteparish & Winterslow|Larkhill, Shrewton & Bulford Camp"))

#generate data if we wanted to look at only August-onwards
sdataugust <- dplyr::filter(sdat, date >="2020-08-01")
#generate data for only the last week
sdatmostrecent <- dplyr::filter(sdat, date >= (Sys.Date()-7))

#reverse order of labels so ggplot plots the areas alphabetically
sdataug2 <- sdataugust %>%
  # reverse order of levels
  mutate(areaName=factor(areaName,levels=rev(sort(unique(areaName)))))

#plot heatmap
gg <- ggplot(sdataug2, aes(x=date, y=areaName, fill=newCasesBySpecimenDateRollingRate)) +
      geom_tile(color="white", size=0.1) +
      coord_fixed(ratio = 8) + 
      scale_fill_viridis(name="Cases per\n100,000 people", label=comma) +
      labs(x=NULL, y=NULL, title="Rolling Seven-Day COVID-19 Rate by MSOA Area", subtitle="Most recent complete data for week ending 28 November") +
      theme_bw() +
      theme(panel.border = element_blank()) + 
      theme(plot.title=element_text(hjust=0, face="bold", size=14)) + 
      theme(plot.subtitle=element_text(hjust=0, size=12)) + 
      theme(axis.ticks=element_blank()) +
      theme(axis.text=element_text(size=12)) + 
      theme(legend.title=element_text(size=12)) +
      theme(legend.text=element_text(size=9)) +
      scale_x_date(expand = c(0, 0),date_breaks = "1 month", date_labels="%b")
gg
