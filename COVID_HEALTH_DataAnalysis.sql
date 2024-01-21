/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject.dbo.CovidDeaths$
order by 1,2
-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, total_cases, population, (total_cases/population)*100 InfectionPercentage
From PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, Max(total_cases) HighestInfection, population, Max((total_cases/population))*100 HighestInfectionPercentage
From PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
Group by location, population
order by population DESC, HighestInfectionPercentage DESC

-- Countries with Highest Death Count per Population
Select location, Max(cast(total_deaths as int)) HighestMortality, population, Max((cast(total_deaths as int)/total_cases))*100 HighestMortalityPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by location, population
order by population DESC, HighestMortality DESC

-- BREAKING THINGS DOWN BY CONTINENT
Select location, Max(cast(total_deaths as int)) HighestMortality, Max((cast(total_deaths as int)/total_cases))*100 HighestMortalityPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is null
Group by location
order by HighestMortality DESC

Select continent, Max(cast(total_deaths as int)) HighestMortality, Max((cast(total_deaths as int)/total_cases))*100 HighestMortalityPercentage
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by continent
order by HighestMortality DESC

-- Global Numbers
Select date, SUM(new_cases ), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100
From PortfolioProject.dbo.CovidDeaths$
Where continent is not null --and new_cases is not null
Group by date
order by date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, Sum(cast(Vacc.new_vaccinations as int)) Over 
(Partition by Dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ Dea
Join PortfolioProject.dbo.CovidVaccinations$ Vacc
on Dea.location = Vacc.location and Dea.date = Vacc.date
Where dea.continent is not null --and new_cases is not null
order by 2,3

-- Use CTE -- 31933
with PopvsVac (continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
as
(Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, Sum(cast(Vacc.new_vaccinations as int)) Over 
(Partition by Dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ Dea
Join PortfolioProject.dbo.CovidVaccinations$ Vacc
on Dea.location = Vacc.location and Dea.date = Vacc.date
Where dea.continent is not null --and new_cases is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table
Drop Table if Exists #PercentPopulationVacc
CREATE TABLE #PercentPopulationVacc
(continent varchar(50),
location varchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVacc
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, Sum(cast(Vacc.new_vaccinations as int)) Over 
(Partition by Dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ Dea
Join PortfolioProject.dbo.CovidVaccinations$ Vacc
on Dea.location = Vacc.location and Dea.date = Vacc.date
Where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVacc

-- View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, Vacc.new_vaccinations
, SUM(CONVERT(int,Vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths$ Dea
Join PortfolioProject.dbo.CovidVaccinations$ Vacc
	On dea.location = Vacc.location
	and dea.date = Vacc.date
where dea.continent is not null 

SELECT * 
from PercentPopulationVaccinated