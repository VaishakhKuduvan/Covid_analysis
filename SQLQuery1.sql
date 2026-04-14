SELECT * 
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccines
--order by 3,4

-- we are selecting the data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelihood if you contracted covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


-- Looking at total cases vs Population 
-- Shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2



-- Looking at Countries with highest Infection rate compared to population 
select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
order by PercentPopulationInfected desc


-- Countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCOunt
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCOunt desc


-- LETS BREAK THIS DOWN BY CONTINENTS!

-- Showing the continents with the highest death count per population 

-- Countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCOunt
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is  null
group by location
order by TotalDeathCOunt desc


-- GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int)) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2

-- GLOBAL NUMBERS
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_deaths as int)) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) 
	as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) * 100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)* 100 
FROM PopvsVac



--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(55),
	Location nvarchar(55),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date) 
	as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) * 100 
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * , (RollingPeopleVaccinated/Population)* 100 
FROM #PercentPopulationVaccinated



USE PortfolioProject;
GO
CREATE OR ALTER VIEW dbo.PercentPopulationvaccinated AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) 
        AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccines vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

Select *
From PercentPopulationvaccinated