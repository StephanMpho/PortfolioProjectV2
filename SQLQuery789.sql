select *
FROM PortfolioProject..CovidDeaths
order by 3,4

--select *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Selecting the data to use in this Project
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the Total Cases VS Total Deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 6) AS DeathRatePercentage
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at the total cases VS Population
-- Shows what percentage of population GOT COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Looking at countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases) / population)*100 AS PercentagePopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Showing the countries with the highest death count per Population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- Let break things down by Continent
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Lets break things down by Continent
-- Showing continents with the higest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Number
-- Showing the daily cases and daily deaths globally
SELECT date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/ sum(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


-- Shows the total cases and total deaths Globally
SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/ sum(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location, dea.location order by dea.location, dea.date) TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- Creating a CTE with the query above

WITH CTE_VacPopulation AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location, dea.location order by dea.location, dea.date) TotalVaccinations
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent is not null
)
Select *, (TotalVaccinations/population)*100 AS VaccinationPercentage
From CTE_VacPopulation

-- Creating a Temp table for the above query which will result in the same result
DROP TABLE IF EXISTS #temp_VacPopulation
CREATE TABLE #temp_VacPopulation (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #temp_VacPopulation
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location, dea.location order by dea.location, dea.date) TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *, (TotalVaccinations/population)*100 AS VaccinationPercentage
From #temp_VacPopulation


-- Creating View to store data for later visualizations

CREATE VIEW VaccinationPercantage as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition BY dea.location, dea.location order by dea.location, dea.date) TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

Select *
FROM VaccinationPercantage