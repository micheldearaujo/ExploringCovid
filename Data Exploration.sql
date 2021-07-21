/*---------------------------------------------------------------------------------------------------------
       
                            Covid Data Exploration Projet
In this project I will perform a exploratory data analysis and data cleaning a a dataset from Covid-19
In this first part of the project I will walk through the dataset and try to make some discovery


*/ --------------------------------------------------------------------------------------------------------
-- From the original downloaded dataset we have extracted two tables, one containing the new cases and deaths info
-- And other containing the tests and vacciations information:

SELECT * FROM death;
SELECT * FROM vaccine;

-- Lets take a look at our tables

SELECT *    -- Ordering the death data by the location and date
FROM death
ORDER BY 3, 4;

SELECT *    -- Ordering the vaccination data by the location and date
FROM vaccine
ORDER BY 3, 4;


--------------\\ Lets filter our data // -------------------------

SELECT LOCATION, date, new_cases, total_cases, total_deaths, population
FROM death
WHERE continent IS NOT NULL;
ORDER BY "location", "date";

-- At this point we can already answer some questions, like
-- What is the percentege of death for each contry through time? In other words,
-- What is the probability of died if you get Covid?
-- We answer this question by create a new column that is a division of the total_deaths by total_cases

SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat((total_deaths::FLOAT/total_cases::FLOAT)*100, '%') AS "lethality_rate"
FROM death
WHERE continent IS NOT NULL;
ORDER BY "location", "date";


-- Now lets take a closer look at Brazil, the country I live in.
SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat(round((total_deaths::NUMERIC/total_cases::NUMERIC)*100, 2), '%') AS "lethality_rate"
FROM death
WHERE "location" = 'Brazil' AND continent IS NOT NULL;
ORDER BY "location", "date";


-- What is the percentage of people that has got Covid?
SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat(round((total_cases::NUMERIC/population::NUMERIC)*100, 2), '%') AS "infection_rate"
FROM death
WHERE "location" = 'Brazil'
ORDER BY "location", "date";


-- Now lets see the countries with the higher overall infection rate
-- We need to select the highest infection_rate of each country

SELECT "location", max(total_cases::NUMERIC) AS "total_cases",
    round((max(total_cases::NUMERIC/population::NUMERIC))*100, 2) AS "infection_rate"
FROM death
WHERE continent IS NOT NULL
GROUP BY "location"
ORDER BY "infection_rate" DESC;


-- What are the countries with the highest death rate?

SELECT "location", max(total_deaths::NUMERIC) AS "total_deaths",
    round((max(total_deaths::NUMERIC/total_cases::NUMERIC))*100, 2) AS "lethality_rate"
FROM death
WHERE ("total_deaths" IS NOT NULL) AND (continent IS NOT NULL)
GROUP BY "location"
ORDER BY "lethality_rate" DESC;
-- There were some countries with 100% of death rate! That is really sad.

-- If you can see, there is a issue with our data. There are locations called "South America", "Asia", and others,
-- when it was supposed to be a country name, not a continent.

SELECT * FROM death
WHERE continent IS NOT NULL; -- Now we have got to add this condition in all the above queries


--

----- \\ Let's break things down by continent now // --------

-- Showing the continents with highest death count
SELECT "location", max(total_deaths::NUMERIC) AS "max_deaths"
FROM death
WHERE continent IS NULL
GROUP BY "location"
ORDER BY "max_deaths" DESC;

SELECT "continent", max(total_deaths::NUMERIC) AS "max_deaths"
FROM death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "max_deaths" DESC;




------ \\ Formating the data to vizualize it in Tableau later on // ------

-- Global numbers
-- Total new cases, new deaths and death rates across the world

SELECT "date", sum(new_cases::NUMERIC) AS "global_new_cases",
                sum(new_deaths::NUMERIC) AS "total_new_deaths",
                round(sum(new_deaths::NUMERIC)/sum(new_cases::NUMERIC), 2)*100 AS "global_lethallity_rate"
FROM death
WHERE continent IS NOT NULL
GROUP BY "date"
ORDER BY "date";


-- And, the overall sum:

SELECT sum(new_cases::NUMERIC) AS "global_new_cases",
                sum(new_deaths::NUMERIC) AS "total_new_deaths",
                round(sum(new_deaths::NUMERIC)/sum(new_cases::NUMERIC), 2)*100 AS "global_lethallity_rate"
FROM death
WHERE continent IS NOT NULL
--group by "date"
--order by "date";


------ \\ Now lets combine our two tables in one // --------

SELECT * FROM death AS d
JOIN vaccine AS v USING("location", "date")
ORDER BY LOCATION, date;


-- Lets look at the percentage of people in the world that are vaccinated
-- For this we can create a cumulative sum of the passing days

-- the basic select
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM death AS d
JOIN vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
ORDER BY LOCATION, date;

-- Now lets create the cumulative sum
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
        sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date) AS "cumulative_vaccination"
            
FROM death AS d
JOIN vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
ORDER BY LOCATION, date;

-- Now we now how many people were vaccinated each day and the total vaccinated people at a specific date.
-- Now we can create another column with the percentage of the population vaccinated each day

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
        sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date) AS "cumulative_vaccination",
                    
                    -- the method bellow is quite ugly to write although it works. But lets re-write this in a
                    -- reader-friendly way
        (sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date)/d.population::NUMERIC)*100 AS "percentage_vaccinated"
            
FROM death AS d
JOIN vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
ORDER BY LOCATION, date;

-- We can use a VIEW

CREATE VIEW cum_vacc AS 
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
        sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date) AS "cumulative_vaccination"

    FROM death AS d
    JOIN vaccine AS v USING("location", "date")
    WHERE d.continent IS NOT NULL
    ORDER BY LOCATION, date;
   
 
SELECT *, (cumulative_vaccination::NUMERIC/population::NUMERIC) AS "percentage_vaccinated"
FROM cum_vacc;

-- We get the same result.




-------- \\ Lets create some views to save tables for later visualizations in Tableau // --------

-- 1. Global new cases, new deaths, global lethallity rate
SELECT sum(new_cases::NUMERIC) AS "global_new_cases",
                sum(new_deaths::NUMERIC) AS "total_new_deaths",
                round(sum(new_deaths::NUMERIC)/sum(new_cases::NUMERIC), 2)*100 AS "global_lethallity_rate"
FROM death
WHERE continent IS NOT NULL

-- 2. Total death count by continent.
SELECT "continent", sum(new_deaths::NUMERIC) AS "total_deaths"
FROM death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "total_deaths" DESC;

-- 3. Total cases, deaths and vaccinations in the world by country
SELECT d.location AS "country",
                sum(new_deaths::NUMERIC) AS "total_deaths",
                sum(new_cases::NUMERIC) AS "total cases",
                sum(v.new_vaccinations::NUMERIC) AS "total_vaccinations"
FROM death AS d
JOIN vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
GROUP BY "location"
ORDER BY d.location;


-- 4. Total cases, deaths, vacctination and vaccination percentage in Brazil through time

CREATE VIEW cum_vacc AS 
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, d.new_deaths, d.new_cases,
        sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date) AS "cumulative_vaccination"

    FROM death AS d
    JOIN vaccine AS v USING("location", "date")
    WHERE d.continent IS NOT NULL
    ORDER BY d.location, d.date;

DROP VIEW cum_vacc


SELECT "date", "location", new_cases, new_deaths, new_vaccinations, cumulative_vaccination, (cumulative_vaccination::NUMERIC/population::NUMERIC) AS "percentage_vaccinated"
FROM cum_vacc
WHERE "location" = 'Brazil'
ORDER BY "date";

-- 5. 
