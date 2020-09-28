library(httr)
library(ukcovid19)
library(dplyr)
library(tidyr)

f1 = list(family="Courier New, monospace", size=12, color="rgb(30,30,30)")

endpoint <- 'https://api.coronavirus.data.gov.uk/v1/data'

query_filters <- c(
  'areaType=ltla',
  'areaName=Wiltshire'
)

cases_and_deaths = list(
  date = "date",
  areaName = "areaName",
  areaCode = "areaCode",
  newCasesBySpecimenDate = "newCasesBySpecimenDate",
  cumCasesByPublishDate = "cumCasesBySpecimenDate"
)

data <- get_data(
  filters = query_filters, 
  structure = cases_and_deaths
)

# Showing the head:
print(head(data))

timestamp <- last_update(
  filters = query_filters, 
  structure = cases_and_deaths
)

print(timestamp)
