library(httr)
library(data.table)  # faster fread() and better weekdays()
library(dplyr)       # consistent data.frame operations
library(purrr)       # consistent & safe list/vector munging
library(tidyr)       # consistent data.frame cleaning
library(lubridate)   # date manipulation
library(ggplot2)     # base plots are for Coursera professors
library(scales)      # pairs nicely with ggplot2 for plot label formatting
library(gridExtra)   # a helper for arranging individual ggplot objects
library(ggthemes)    # has a clean theme for ggplot2
library(viridis)     # best. color. palette. evar.
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

sdataugust <- dplyr::filter(sdat, date >="2020-08-01")
sdatmostrecent <- dplyr::filter(sdat, date >= (Sys.Date()-7))

sdat$areaName <- factor(sdat$areaName, levels = sdatmostrecent$areaName)
reorder(sdat$areaName, sdat$newCasesBySpecimenDateRollingRate)

sdat$areaName <- factor(x = sdat$areaName,
                               levels = otter.scaled$accession[otter.order], 
                               ordered = TRUE)

sdat2 <- sdat %>%
  # convert state to factor and reverse order of levels
  mutate(areaName=factor(areaName,levels=rev(sort(unique(areaName)))))


gg <- ggplot(sdat2, aes(x=date, y=areaName, fill=newCasesBySpecimenDateRollingRate)) +
      geom_tile(color="white", size=0.1) +
      coord_fixed(ratio = 8) + 
      scale_fill_viridis(name="Cases per\n100,000 people", label=comma) +
      labs(x=NULL, y=NULL, title="Rolling COVID-19 Rate by MSOA Area") +
      theme_bw() +
      theme(panel.border = element_blank()) + 
      theme(plot.title=element_text(hjust=0)) + 
      theme(axis.ticks=element_blank()) +
      theme(axis.text=element_text(size=12)) + 
      theme(legend.title=element_text(size=12)) +
      theme(legend.text=element_text(size=9)) +
      scale_x_date(expand = c(0, 0))
gg

yy <- ggplot(sdat, aes(x=date, y=areaName, fill=newCasesBySpecimenDateRollingSum)) +
  geom_tile(color="white") +
  coord_fixed(ratio = 8) + 
  scale_fill_viridis(name="Rolling Sum", label=comma) +
  labs(x=NULL, y=NULL, title="Rolling COVID-19 Sums by MSOA Area") +
  theme_bw() +
  theme(panel.border = element_blank()) + 
  theme(plot.title=element_text(hjust=0)) + 
  theme(axis.ticks=element_blank()) +
  theme(axis.text=element_text(size=12)) + 
  theme(legend.title=element_text(size=12)) +
  theme(legend.text=element_text(size=9)) 
yy
  
data$item <- reorder(data$item,data$tot)
