/*

Queries used for Tableau Project

*/



-- 1. Create columns for total_cases from sum of new_cases, total_deaths from sum of new_deaths and calculate the DeathPercentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2



-- 2. Calculating the sum of cases per Continent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Calculate the HighestInfectionCount from the maximum of total_cases and PercentPopulationInfected from the percentage of maximum total_cases per population fo each Location

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Calculate the HighestInfectionCount from the maximum of total_cases and PercentPopulationInfected from the percentage of maximum total_cases per population


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
