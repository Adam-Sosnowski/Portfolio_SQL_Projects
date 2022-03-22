/*

Queries used for Tableau Covid project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
-- Group By date
Order by 1,2



-- 2. 

-- I'm taking these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount DESC



-- 3.

Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected DESC



-- 4.

Select location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected DESC