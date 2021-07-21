"""  
Separating some columns of the original dataset to create two separate tables in SQL
The first one containing the cases and deaths information
and the second one containing the vaccinations and other personal informations

@micheldearaujo     created at SUN 2021 July 18 20:30

"""
# Importing the used libraries
import pandas as pd

# Loading the dataset from a CSV file
covid_data = pd.read_csv('owid-covid-data.csv')

# Checking out the columns names
print(covid_data.columns)

# Creating a table only for the cases and deaths
deaths = covid_data[['iso_code', 'continent', 'location', 'date', 'population','total_cases', 'new_cases',
       'new_cases_smoothed', 'total_deaths', 'new_deaths',
       'new_deaths_smoothed', 'total_cases_per_million',
       'new_cases_per_million', 'new_cases_smoothed_per_million',
       'total_deaths_per_million', 'new_deaths_per_million',
       'new_deaths_smoothed_per_million', 'reproduction_rate', 'icu_patients',
       'icu_patients_per_million', 'hosp_patients',
       'hosp_patients_per_million', 'weekly_icu_admissions',
       'weekly_icu_admissions_per_million', 'weekly_hosp_admissions',
       'weekly_hosp_admissions_per_million']]

# Creating another table only for the tests and vaccination and other informations
vaccines = covid_data[['iso_code', 'continent', 'location', 'date', 'population', 'new_tests', 'total_tests',
       'total_tests_per_thousand', 'new_tests_per_thousand',
       'new_tests_smoothed', 'new_tests_smoothed_per_thousand',
       'positive_rate', 'tests_per_case', 'tests_units', 'total_vaccinations',
       'people_vaccinated', 'people_fully_vaccinated', 'new_vaccinations',
       'new_vaccinations_smoothed', 'total_vaccinations_per_hundred',
       'people_vaccinated_per_hundred', 'people_fully_vaccinated_per_hundred',
       'new_vaccinations_smoothed_per_million', 'stringency_index', 
       'population_density', 'median_age', 'aged_65_older',
       'aged_70_older', 'gdp_per_capita', 'extreme_poverty',
       'cardiovasc_death_rate', 'diabetes_prevalence', 'female_smokers',
       'male_smokers', 'handwashing_facilities', 'hospital_beds_per_thousand',
       'life_expectancy', 'human_development_index', 'excess_mortality']]

# Exporting the tables
deaths.to_csv('./data/deaths.csv', index=False)
vaccines.to_csv('./data/vaccination.csv', index=False)