# load libraries
library(dplyr)

# get COVID-19 data file from "https://ourworldindata.org/coronavirus-data"
# link to csv file: "https://covid.ourworldindata.org/data/owid-covid-data.csv"

fileURL <- "https://covid.ourworldindata.org/data/owid-covid-data.csv"

# download file from internet then load it to R
download.file(fileURL,destfile = "./covid-19.csv") 
covid19 <- read.table("./covid-19.csv", header = TRUE, sep = ",", quote = "")

nrow(covid19) # check count of rows loaded to R
head(covid19) # see how data looks like

# check what columns (variables) we have in the data file
names(covid19)

# keep columns we need in the analysis (col index: 1,2,3,4,5,7,21)
covid19_short <- covid19 %>% select(c(1,2,3,4,5,7,21))

# remove rows with "International" and "World" locations to keep countries only
covid19_short <- covid19_short %>% 
  filter(location != "World" & location != "International")

nrow(covid19_short) # check number of remaining rows

# rename few columns to shorter names
covid19_short <- covid19_short %>% rename(code = "iso_code", country = "location", 
                                          cases = "total_cases", deaths = "total_deaths")

# Since the data is cumulative, keep rows of the maximum date for each country
covid19_short <-  covid19_short %>% slice_max(order_by = date)

# add two new calculated (mutated) columns: 
# cases_perc: which is percentage of cases to population
# death_perc: which is percentage of deaths to cases

covid19_short <- covid19_short %>%
  mutate(cases_perc = round((cases/population)*100,digits = 2), 
         death_perc = round((deaths/cases)*100,digits = 2))

# summarize total cases and total deaths per continent
covid19_continent <- covid19_short %>%
  group_by(continent) %>%
  summarise(todate_cases = sum(cases), todate_deaths = sum(deaths))

# add death_rate to the "continent" table
covid19_continent <- covid19_continent %>%
  mutate(death_perc = round(((todate_deaths/todate_cases)*100), digits = 2))


# reorder continent table by death rate. Save to covid19_continent_by_death_rate
covid19_continent_by_death_rate <- covid19_continent %>%
  arrange(desc(death_perc))

# print top-15 countries in terms of cases_rate. Save to covid19_country_by_cases_rate
covid19_country_by_cases_rate <- covid19_short %>%
  slice_max(order_by = cases_perc, n = 15)

# print top-15 countries in terms of deaths_rate. Save to covid19_country_by_death_rate
covid19_country_by_death_rate <- covid19_short %>%
  slice_max(order_by = death_perc, n = 15)

# view all final tables
View(covid19_continent_by_death_rate)
View(covid19_country_by_death_rate)
View(covid19_country_by_cases_rate)


##END