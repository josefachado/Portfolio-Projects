--Data Analyst Portfolio Project - SQL Data Exploration - Project 1
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows percentage of you likely dying in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Neth%' AND continent IS NOT NULL
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows percentage of population that got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Neth%'
ORDER BY 1, 2


-- Looking at countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Neth%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC


-- Looking at countries with highest deathcount vs population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Neth%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- LET 'S BREAK THINGS DOWN BY CONTINENT
-- Looking at continents with highest deathcount vs population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Neth%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


-- Global numbers
SELECT /*date,*/ SUM(new_cases) AS TotalNewCases, sum(CAST(new_deaths AS int)) AS TotalNewDeaths, sum(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS CaseDeathePercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, RollingPeopleVaccinated/Population *100 AS PercentagePopulationVaccinated
FROM PopvsVac


--TEMP Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
 
SELECT *, RollingPeopleVaccinated/Population *100 AS PercentagePopulationVaccinated
FROM #PercentagePopulationVaccinated


-- Creating View for storing data for later visualisations
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *
FROM PercentagePopulationVaccinated
