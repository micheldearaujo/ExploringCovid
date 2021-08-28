/*---------------------------------------------------------------------------------------------------------
       
                            Covid Data Exploration Projet
In this project I will perform a exploratory data analysis and data cleaning a a dataset from Covid-19
In this first part of the project I will walk through the dataset and try to make some discovery

Dashboard: https://public.tableau.com/app/profile/michel.de.ara.jo/viz/COVID-19innumbers_16268902575460/Dashboard1?publish=yes
*/ --------------------------------------------------------------------------------------------------------

-- From the original downloaded dataset we have extracted two tables, one containing the new cases and deaths info
-- And other containing the tests and vacciations information:

SELECT * FROM death;
SELECT * FROM vaccine;

-- Lets take a look at our tables

SELECT *    -- Ordering the death data by the location and date
FROM "Covid19".death
ORDER BY 3, 4;

SELECT *    -- Ordering the vaccination data by the location and date
FROM vaccine
ORDER BY 3, 4;


--------------\\ Lets filter our data // -------------------------

SELECT LOCATION, date, new_cases, total_cases, total_deaths, population
FROM death
WHERE continent IS NOT NULL; -- There are some rows where the continent is NULL. When it happens, the continent name is in the location
                                -- column
ORDER BY "location", "date";

-- At this point we can already answer some questions, like
-- What is the percentege of death for each contry through time? In other words,
-- What is the probability of dying if you get infected by COVID?
-- To answer this question I will create a new column that is a division of the total_deaths by total_cases

SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat((total_deaths::FLOAT/total_cases::FLOAT)*100, '%') AS "lethality_rate"
FROM "Covid19".death
WHERE continent IS NOT NULL
ORDER BY "location", "date";

-- So we now have the "Lethallity rate" which tell us the percent of people who died after get infected by COVID day by day in each country.



-- Now lets take a closer look at Brazil, the country I live in.
SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat(round((total_deaths::NUMERIC/total_cases::NUMERIC)*100, 2), '%') AS "lethality_rate"
FROM death
WHERE "location" = 'Brazil' AND continent IS NOT NULL
ORDER BY "location", "date";

-- As you can see, this probability starts at zero, when no one has died yet, and quickly jumps to 6% and almost 7%!
-- And them the number starts to fall down.
-- A possible explanation for this behavior is that in the beginning people were not believing in the COVID-19 pandemic
-- and refused to seek medical assistance. Then, after a some cases appeared on TV, people started to make the right decision and go to the hospitals to have medical assistance.



-- What is the percentage of people that has got COVID-19 in Brazil?
SELECT "location", "date", new_cases, total_cases, total_deaths, population,
    concat(round((total_cases::NUMERIC/population::NUMERIC)*100, 2), '%') AS "infection_rate"
FROM death
WHERE "location" = 'Brazil'
ORDER BY "location", "date";


-- Now lets see the countries with the higher overall infection rate
-- We need to select the highest infection_rate of each country

SELECT "location", max(total_cases::NUMERIC) AS "total_cases", -- using max() to select the highest infection rate
    round((max(total_cases::NUMERIC/population::NUMERIC))*100, 2) AS "infection_rate"
FROM death
WHERE continent IS NOT NULL
GROUP BY "location"             -- Grouping by country. So the max() function will returns the highest of each country.
ORDER BY "infection_rate" DESC;


-- What are the countries with the highest lethality rate?
SELECT "location", max(total_deaths::NUMERIC) AS "total_deaths",
    round((max(total_deaths::NUMERIC/total_cases::NUMERIC))*100, 2) AS "lethality_rate"
FROM death
WHERE ("total_deaths" IS NOT NULL) AND (continent IS NOT NULL)
GROUP BY "location"
ORDER BY "lethality_rate" DESC;
-- There were some countries with 100% of lethality rate! That is really sad.
-- But there is a least tragic explanation for that number. In the very beginning of the pandemic there were none cases registered
-- until someone passed way. So, all registered cases corresponds to registered deaths.


-- If you can see, there is a issue with our data. There are locations called "South America", "Asia", and others,
-- when it was supposed to be a country name, not a continent.

SELECT * FROM death
WHERE continent IS NOT NULL; -- Now we have got to add this condition in all the above queries


--

----- \\ Let's break things down by continent now // --------

-- Showing the continents with highest death count

-- This query counts with international waters, European Union and the whole World.
SELECT "location", max(total_deaths::NUMERIC) AS "max_deaths"
FROM death
WHERE continent IS NULL
GROUP BY "location"
ORDER BY "max_deaths" DESC;


-- As for the bellow one takes into account only the geographical continents
SELECT "continent", max(total_deaths::NUMERIC) AS "max_deaths"
FROM death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "max_deaths" DESC;



------ Global numbers
-- Total new cases, new deaths and death rates across the world throught time

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

-- Now lets create the cumulative sum using window functions
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
        sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date) AS "cumulative_vaccination"
            
FROM death AS d
JOIN vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
ORDER BY LOCATION, date;

-- When we use a aggregate function with the "partition by" statement we create a new column containing the result
-- of the aggregate function grouped into the groups specified. But, when we add the "Order By" this result
-- becomes, in the sum() case, the cumulative sum of each group!


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




-------- \\ Lets exports some queries for tables to create visualizations in Tableau // --------

-- To make sure that all data you be well-read in Tableau, lets change the NULL values to zero.


-- 1. Global total cases, total deaths, global lethallity rate
SELECT sum(new_cases::NUMERIC) AS "global_total_cases",
                sum(new_deaths::NUMERIC) AS "total_deaths",
                round(sum(new_deaths::NUMERIC)/sum(new_cases::NUMERIC), 2)*100 AS "global_lethallity_rate"
FROM "Covid19".death
WHERE continent IS NOT NULL;

-- 2. Total death count by continent.
SELECT "continent", sum(new_deaths::NUMERIC) AS "total_deaths"
FROM "Covid19".death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY "total_deaths" DESC;

-- 3. Total cases, deaths and vaccinations in the world by country
SELECT d.location AS "country",
                COALESCE(sum(new_deaths::NUMERIC), 0) AS "total_deaths",
                COALESCE(sum(new_cases::NUMERIC), 0) AS "total cases",
                COALESCE(sum(v.new_vaccinations::NUMERIC), 0) AS "total_vaccinations",
                COALESCE((sum(new_cases::NUMERIC)/avg(d.population::NUMERIC))*100, 0) AS "infection_rate"
FROM "Covid19".death AS d
JOIN "Covid19".vaccine AS v USING("location", "date")
WHERE d.continent IS NOT NULL
GROUP BY "location"
ORDER BY d.location;


-- 4. Total cases, deaths, vacctination and vaccination percentage in Brazil through time
DROP VIEW IF EXISTS cum_vacc;
CREATE VIEW cum_vacc AS 
    SELECT d.continent, d.location, d.date, d.population,
        COALESCE(v.new_vaccinations::NUMERIC, 0) AS "new_vaccinations",
        COALESCE(d.new_deaths::NUMERIC, 0) AS "new_deaths",
        COALESCE(d.new_cases::NUMERIC, 0) AS "new_cases",
        COALESCE(sum(v.new_vaccinations::NUMERIC)
            OVER (PARTITION BY d.location
                  ORDER BY d.location, d.date), 0) AS "cumulative_vaccination"

    FROM "Covid19".death AS d
    JOIN "Covid19".vaccine AS v USING("location", "date")
    WHERE d.continent IS NOT NULL
    ORDER BY d.location, d.date;


SELECT "date", "location", new_cases, new_deaths, new_vaccinations, cumulative_vaccination, (cumulative_vaccination::NUMERIC/population::NUMERIC)*100 AS "percentage_vaccinated"
FROM cum_vacc
WHERE "location" = 'Brazil'
ORDER BY "date";

-- 5. 
