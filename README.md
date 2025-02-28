# Covid-19-DATA-ANALYSIS-
# COVID-19 Data Analysis in R

## Overview
This project analyzes COVID-19 data using R and the `dplyr` library. The dataset is sourced from Our World in Data and provides insights into total cases, total deaths, and case/death percentages across different countries and continents. The analysis focuses on extracting key metrics and summarizing them effectively.

## Data Source
The dataset used in this project is obtained from Our World in Data:
- **CSV File URL**: [https://covid.ourworldindata.org/data/owid-covid-data.csv](https://covid.ourworldindata.org/data/owid-covid-data.csv)

## Steps in the Analysis
1. **Load Required Libraries**  
   The `dplyr` package is used for data manipulation.
   ```r
   library(dplyr)
   ```

2. **Download and Read Data**  
   The dataset is downloaded and loaded into R.
   ```r
   fileURL <- "https://covid.ourworldindata.org/data/owid-covid-data.csv"
   download.file(fileURL, destfile = "./covid-19.csv") 
   covid19 <- read.table("./covid-19.csv", header = TRUE, sep = ",", quote = "")
   ```

3. **Data Inspection**  
   - Checking the number of rows loaded
   - Viewing column names
   - Displaying sample data

4. **Selecting Relevant Columns**  
   Only necessary columns are retained for analysis.
   ```r
   covid19_short <- covid19 %>% select(c(1,2,3,4,5,7,21))
   ```

5. **Filtering Data**  
   - Removing rows with "World" and "International" locations.
   ```r
   covid19_short <- covid19_short %>% filter(location != "World" & location != "International")
   ```

6. **Renaming Columns**  
   Column names are shortened for better readability.
   ```r
   covid19_short <- covid19_short %>% rename(code = "iso_code", country = "location", 
                          cases = "total_cases", deaths = "total_deaths")
   ```

7. **Extracting Latest Data**  
   Since the dataset is cumulative, only the latest date per country is retained.
   ```r
   covid19_short <- covid19_short %>% slice_max(order_by = date)
   ```

8. **Creating New Calculated Columns**  
   - `cases_perc`: Percentage of cases relative to population
   - `death_perc`: Percentage of deaths relative to cases
   ```r
   covid19_short <- covid19_short %>%
     mutate(cases_perc = round((cases/population)*100,digits = 2), 
            death_perc = round((deaths/cases)*100,digits = 2))
   ```

9. **Summarizing Data by Continent**  
   - Summarizing total cases and deaths per continent.
   - Adding a `death_perc` column.
   ```r
   covid19_continent <- covid19_short %>%
     group_by(continent) %>%
     summarise(todate_cases = sum(cases), todate_deaths = sum(deaths)) %>%
     mutate(death_perc = round(((todate_deaths/todate_cases)*100), digits = 2))
   ```

10. **Sorting and Filtering Data**  
    - Sorting continents by death rate.
    - Selecting the top 15 countries based on case and death percentages.
    ```r
    covid19_continent_by_death_rate <- covid19_continent %>% arrange(desc(death_perc))
    covid19_country_by_cases_rate <- covid19_short %>% slice_max(order_by = cases_perc, n = 15)
    covid19_country_by_death_rate <- covid19_short %>% slice_max(order_by = death_perc, n = 15)
    ```

11. **Viewing Final Tables**  
    The results are displayed using the `View()` function.
    ```r
    View(covid19_continent_by_death_rate)
    View(covid19_country_by_death_rate)
    View(covid19_country_by_cases_rate)
    ```

## Requirements
- R (version 4.0 or later recommended)
- `dplyr` package

## Usage
1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/covid19-data-analysis.git
   ```
2. Open and run the `covid_analysis.R` script in RStudio or any R environment.

## License
This project is licensed under the MIT License.

