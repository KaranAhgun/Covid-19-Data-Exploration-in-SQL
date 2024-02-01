SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null

--SELECT *
--FROM PortfolioProject..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if infected
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%australia'

--Looking at Total cases vs population
--Shows what percentage of the population was infected

SELECT location, date, total_cases,population, (total_cases/population)*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%australia'

--Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%australia'
GROUP BY location,population
ORDER BY PercentagePopInfected desc

--Looking at countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%australia'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Breaking down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%australia'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/ SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%australia'
where continent is not null
GROUP BY date
order by 1,2

--Joining tables

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Cumulative Vaccination Count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVacCount
--, (CumulativeVacCount/population)*100 as PercentageVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Using CTE (use different variables in spare time)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVacCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVacCount
--, (CumulativeVacCount/population)*100 as PercentageVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (CumulativeVacCount/Population)*100
From PopvsVac


--Using Temp Table

Create Table #PercentPopVac
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVacCount numeric
)

Insert into #PercentPopVac
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVacCount
--, (CumulativeVacCount/population)*100 as PercentageVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select*, (CumulativeVacCount/Population)*100
From #PercentPopVac

--Create View to store data for visualisation

Create View PercentPopVac as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVacCount
--, (CumulativeVacCount/population)*100 as PercentageVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3