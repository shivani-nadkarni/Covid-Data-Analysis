SELECT 
	*
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 3,4;

-- Select Data that we are going to be using
SELECT 
	location, date, total_cases, new_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1, 2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in the given country

SELECT 
	location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL 
	AND location='India'
ORDER BY 
	1, 2;

-- Looking at Total Cases vs Population

SELECT 
	location, date, population, total_cases, (total_cases/population)*100 as casesPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL 
	AND location='India'
ORDER BY 
	1, 2;

-- Looking at countries with highest infection rate compared to population

SELECT
	location, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as infectedPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	infectedPercentage DESC;

-- Showing countries with Highest Death Count compared to population

SELECT
	location, MAX(CAST(total_deaths AS int)) as highestDeathCount, MAX((total_deaths/population)*100) as deathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location
ORDER BY
	highestDeathCount DESC;

-- Showing continents with highest Death Count
SELECT
	location, MAX(CAST(total_deaths AS int)) as highestDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NULL
GROUP BY
	location
ORDER BY
	highestDeathCount DESC;

-- Global Numbers every day since the outbreak
SELECT 
	date, SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	date
ORDER BY 
	1, 2;

-- Global death percentage till date

SELECT 
	SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1, 2;


-- Looking at Total Population vs Vaccinations (using Partition by)

SELECT 
	deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(INT, vaccinations.new_vaccinations)) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths deaths
JOIN
	PortfolioProject..CovidVaccinations vaccinations
ON
	deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE
	deaths.continent IS NOT NULL
ORDER BY
	2, 3;

-- Use CTE (Common table Expression)
WITH 
	PopVsVacc (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
AS (
	SELECT 
		deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
		SUM(CONVERT(INT, vaccinations.new_vaccinations)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths deaths
	JOIN
		PortfolioProject..CovidVaccinations vaccinations
	ON
		deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE
		deaths.continent IS NOT NULL
) 

SELECT 
	*, (rollingPeopleVaccinated/population)*100 
FROM
	PopVsVacc
ORDER BY
	2, 3;

-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE 
	#PercentPopulationVaccinated(
		continent nvarchar(255),
		location nvarchar(255),
		date datetime,
		population numeric,
		new_vaccinations numeric,
		rolling_people_vaccinated numeric
);

INSERT INTO 
	#PercentPopulationVaccinated
SELECT 
	deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
	SUM(CONVERT(INT, vaccinations.new_vaccinations)) 
	OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths deaths
JOIN
	PortfolioProject..CovidVaccinations vaccinations
ON
	deaths.location = vaccinations.location
	AND deaths.date = vaccinations.date
WHERE
	deaths.continent IS NOT NULL
ORDER BY
	2, 3;

SELECT * FROM #PercentPopulationVaccinated;

-- Creating a view to store data for later visualisations

DROP VIEW IF EXISTS PercentPopulationVaccinated;
CREATE VIEW 
	PercentPopulationVaccinated 
AS 
	SELECT 
		deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations,
		SUM(CONVERT(INT, vaccinations.new_vaccinations)) 
		OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS rollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths deaths
	JOIN
		PortfolioProject..CovidVaccinations vaccinations
	ON
		deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE
		deaths.continent IS NOT NULL

-- queries for visualisations

-- 1..

SELECT 
	SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
ORDER BY 
	1, 2;

-- 2..

SELECT 
	location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NULL
	AND location not in ('World', 'European Union', 'International')
GROUP BY 
	location
ORDER BY
	TotalDeathCount DESC

-- 3..

SELECT
	location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as infectedPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population
ORDER BY
	infectedPercentage DESC;

-- 4 ..

SELECT
	location, population, date, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population)*100) as infectedPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	location, population, date
ORDER BY
	infectedPercentage DESC;
