SELECT * FROM
PortfolioProject..CovidDeaths
WHERE Continent is not null
ORDER BY 3,4

--SELECT * FROM
--PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select data that we are going to be using

SELECT Location, date, new_cases, total_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Total Case vs Population
--Shows what percentage has Covid

SELECT Location, date, population, total_cases,  (total_cases/population)* 100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, Max(total_cases) as HihestInfectionCount,  Max((total_cases/population))* 100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count by Population

SELECT Location, MAX(cast(Total_deaths as int))TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


--BREAKING THINGS DOWN BY CONTINENT


SELECT continent, MAX(cast(Total_deaths as int))TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population


SELECT continent, MAX(cast(Total_deaths as int))TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from  dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent is not null
	ORDER BY 2,3


	--USE CTE

	WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	AS
	(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from  dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent is not null
	--ORDER BY 2,3
	)
	select * , (RollingPeopleVaccinated/Population)*100
	from PopvsVac

	--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



INSERT INTO #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from  dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent is not null
	--ORDER BY 2,3
	select * , (RollingPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated

	
	
	--Creating View to store for later visualizations

	CREATE VIEW PercentPopulationVaccinated as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from  dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
ON dea.location = vac.location
	AND dea.date = vac.date
	where dea.continent is not null
	--ORDER BY 2,3

	SELECT * 
	FROM PercentPopulationVaccinated
