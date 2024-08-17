-- Ttoal Cases vs Total Deaths in Colombia

SELECT 
    "location", 
    "date", 
    total_cases, 
    new_cases, 
    total_deaths, 
    population, 
    ROUND((CAST(total_deaths AS NUMERIC) / NULLIF(total_cases, 0)) * 100, 2) AS death_rate
FROM 
    "CovidDeaths" cd
WHERE "location" = 'Colombia'
ORDER BY 
    "location", 
    "date"

-- Looking at Total Cases vs Population: Shows what percentage of population got Covid at any given date    

SELECT 
    "location", 
    "date",
    population,
    total_cases,
    CAST(total_cases AS NUMERIC) / NULLIF(population, 0) * 100 AS infection_rate
FROM "CovidDeaths" cd
ORDER BY 
	"location", 
	"date" 
	
-- Countries with the highest infection rate compared to population

SELECT 
    "location", 
    population,
    MAX(total_cases) AS highest_infection_count,
    MAX(CAST(total_cases AS NUMERIC) / NULLIF(population, 0))*100 AS highest_infection_rate
FROM "CovidDeaths" cd
GROUP BY "location", population
HAVING MAX(CAST(total_cases AS NUMERIC) / NULLIF(population, 0))*100 IS NOT NULL
ORDER BY 
	highest_infection_rate DESC

--Countris with the highest death rate compared to population

SELECT 
    "location", 
    population,
    MAX(total_deaths) AS highest_death_count,
    MAX(CAST(total_deaths AS NUMERIC) / NULLIF(population, 0))*100 AS highest_death_rate
FROM "CovidDeaths" cd
GROUP BY "location", population
HAVING MAX(CAST(total_deaths AS NUMERIC) / NULLIF(population, 0))*100 IS NOT NULL
ORDER BY 
	highest_death_rate DESC

-- Countries with highest death count
	
SELECT 
    "location", 
    MAX(total_deaths) AS max_total_deaths
FROM "CovidDeaths" cd
GROUP BY "location"
HAVING max(total_deaths) IS NOT NULL 
ORDER BY max_total_deaths DESC

-- Deaths by continent
	
SELECT 
    continent, 
    SUM(total_deaths) AS total_deaths
FROM "CovidDeaths"
GROUP BY continent
ORDER BY total_deaths DESC;

--Death rate in the world by day

SELECT "date", SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_deaths, SUM(CAST(new_deaths AS NUMERIC))/NULLIF(SUM(new_cases),0)*100 AS death_rate
FROM "CovidDeaths" cd
GROUP BY "date"
ORDER BY "date"

-- Looking at Total Population v Vaccinations

SELECT cd.continent,
	cd."location",
	cd."date",
	cd.population,
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd."location" ORDER BY cd."date") AS cumulative_total_vaccinations_by_location,
	--((SUM(cv.new_vaccinations) OVER (PARTITION BY cd."location" ORDER BY cd."date"))/cd.population)*100 AS percentage_of_people_vaccinated
FROM "CovidDeaths" cd 
JOIN "CovidVaccinations" cv 
	ON cd."location" = cv."location" 
	AND cd."date" = cv."date"
ORDER BY 2,3

-- Looking at Total Population v Vaccinations using a CTE

WITH CumulativeVaccinations AS (
	SELECT cd.continent,
	cd."location",
	cd."date",
	cd.population,
	cv.new_vaccinations,
	SUM(cv.new_vaccinations) OVER (PARTITION BY cd."location" ORDER BY cd."date") AS cumulative_total_vaccinations_by_location
	FROM "CovidDeaths" cd 
	JOIN "CovidVaccinations" cv 
		ON cd."location" = cv."location" 
		AND cd."date" = cv."date"
	ORDER BY 2,3
)

SELECT *, (cumulative_total_vaccinations_by_location/population)*100 AS percentage_of_people_vaccinated
FROM CumulativeVaccinations









