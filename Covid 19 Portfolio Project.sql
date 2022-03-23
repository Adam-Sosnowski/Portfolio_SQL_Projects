/*
Covid 19 data exploration using Microsoft SQL Server Management Studio.

Created and uploaded two tables, based on data available on https://ourworldindata.org/covid-deaths

Included: basic queries, Joins, CTEs, Temp Tables, Window functions, Aggregate functions, creating views, converting data types.

*/


Select *
From PortfolioProject..Covid_Deaths
Where continent is not null
order by 3,4



-- Select data that I'm going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
Where continent is not null
Order by 1,2



-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Ireland

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..Covid_Deaths
Where continent is not null
Where location like 'Ireland'
Order by 1,2



-- Looking at total cases vs population
-- Shows what percentage of population contracted the virus in Ireland

Select location, date, population, total_cases, (total_cases/population)*100 AS infection_percentage
From PortfolioProject..Covid_Deaths
Where continent is not null
Where location like 'Ireland'
Order by 1,2



-- List countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS infection_rate
From PortfolioProject..Covid_Deaths
Where continent is not null
--Where location like 'Ireland'
Group by location, population
Order by 4 DESC



-- List of coutries with highest death count per population

Select location, population, MAX(CAST(total_deaths AS INT)) AS total_deaths
From PortfolioProject..Covid_Deaths
Where continent is not null
--Where location like 'Ireland'
Group by location, population
Order by 3 DESC



-- List of coutries with highest death rate per population

Select location, population, MAX(CAST(total_deaths AS INT)) AS total_deaths, MAX((total_deaths/population))*100 AS death_rate
From PortfolioProject..Covid_Deaths
Where continent is not null
--Where location like 'Ireland'
Group by location, population
Order by 4 DESC



-- BREAKDOWN BY CONTINENT
-- Showing continents with highest death count

Select continent, MAX(CAST(total_deaths AS INT)) AS total_deaths
From PortfolioProject..Covid_Deaths
Where continent is not null
--Where location like 'Ireland'
Group by continent
Order by total_deaths DESC



-- GLOBAL NUMBERS
-- Listed per day

Select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
From PortfolioProject..Covid_Deaths
Where continent is not null
Group by date
Order by 1,2



-- Global numbers
-- Total numbers as of 20 March 2022

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
From PortfolioProject..Covid_Deaths
Where continent is not null
--Group by date
--Order by 1,2



-- Review the Vaccination table

Select *
From PortfolioProject..Covid_Vaccinations
order by 3,4



-- Join the two tables

Select *
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date



-- List of new vaccinations vs total population, per day

Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date
Where deaths.continent is not null
Order by 2,3



-- List of new vaccinations and running total of vaccinations, per day

Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) AS vaccination_running_total
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date
Where deaths.continent is not null
Order by 2,3



-- Using CTE
-- calculating vaccination rate, running total per day
-- using CTE to perform calculation on Partition By in previous query

With PopVsVac (continent, location, date, population, new_vaccinations, vaccination_running_total)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) AS vaccination_running_total
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date
Where deaths.continent is not null
--Order by 2,3
)
Select *, (vaccination_running_total/population)*100 AS vaccination_rate
From PopVsVac



-- Using TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccination_running_total numeric
)

Insert into #PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) AS vaccination_running_total
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date
Where deaths.continent is not null
--Order by 2,3

Select *, (vaccination_running_total/population)*100 AS vaccination_rate
From #PercentPopulationVaccinated



-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) AS vaccination_running_total
From PortfolioProject..Covid_Deaths deaths
JOIN PortfolioProject..Covid_Vaccinations vac
  ON deaths.location = vac.location
  and deaths.date = vac.date
Where deaths.continent is not null
