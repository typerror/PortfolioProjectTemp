Select *
From PortfolioProject1..CovidDeaths
where continent is not null
Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs. Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
where location like '%canada%'
order by 1, 2

-- Looking at Total Cases vs. Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationInfPercentage
From PortfolioProject1..CovidDeaths
where location like '%canada%'
order by 1, 2

-- Looking at countries with Highest Infection Rate compared to Population

Select Location, MAX(total_cases) as HighestInfCount, MAX((total_cases/population))*100 as PopulationInfPercentage
From PortfolioProject1..CovidDeaths
Group by Location, Population
order by PopulationInfPercentage desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Showing continents with highest death count per population

Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
where continent is not null
Group by Continent
order by TotalDeathCount desc

-- Global Numbers

Select Date, SUM(New_Cases) as total_cases, SUM(cast(New_Deaths as int)) as total_deaths, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Group By date
Order by 1, 2

-- TOTAL GLOBAL NUMBERS

Select SUM(New_Cases) as total_cases, SUM(cast(New_Deaths as int)) as total_deaths, SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null
Order by 1, 2

-- Looking at Total Populaion vs. Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
DROP TABLE if exists #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulationVaccinatedPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PopulationVaccinatedPercentage

-- Creating View to store data

Create View PopulationVaccinatedPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From PortfolioProject1.. CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PopulationVaccinatedPercentage