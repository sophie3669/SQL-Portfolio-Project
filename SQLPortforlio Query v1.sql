--select *
--from PortfolioProject.dbo.covidDeaths
--order by 1,2


--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
--from PortfolioProject..covidDeaths
--order by 1,2

--looking at the total cases vs total deaths
--shows the likelihood of deaths in your country if you contract covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS Deathpercentage
FROM PortfolioProject..covidDeaths
where location like '%ia'
order by 1,2


--looking at the total cases vs the population
--Shows what percentage got covid

SELECT location, date,population, total_cases, (total_cases/population)* 100 AS percentagecases
FROM PortfolioProject..covidDeaths
where location like '%N%geria'
order by 1,2


--looking at countries with the highest infection rates copared to the population

SELECT location,population, MAX(total_cases) As MaxInfectedCountry, max((total_cases/population))* 100 AS percentagecases
FROM PortfolioProject..covidDeaths
group by location, population
order by 4 desc


--showing countries with highest death count per population

select location, max(total_deaths) as totalDeathCount
FROM PortfolioProject..covidDeaths
where continent is Not NULL
group by location
order by 2 desc


--Breaking down by continent
--showing continents with the highest death count


select continent, max(total_deaths) as totalDeathCount
FROM PortfolioProject..covidDeaths
where continent is not NULL
group by continent
order by 2 desc



--Global queries
select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
FROM PortfolioProject..covidDeaths
where continent is not NULL 
and new_cases > 0
and new_deaths > 0
Group by date
order by 1,2


--Global queries 2

select sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
FROM PortfolioProject..covidDeaths
where continent is not NULL 
and new_cases > 0
and new_deaths > 0
order by 1,2


--Joining 2 tables togeher

select *
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date


-- Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is Not Null
order by 1,2,3



--Using the partition function to make a rolling count:

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rollingVaccinationCount
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is Not Null
order by 2,3


--Using a CTE to check how many people in a country are vaccinated.

 with PopVsVacc (continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
 as
 (select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rollingVaccinationCount
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is Not Null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Population)*100 as percentagevaccinatedPeople
from PopVsVacc



--Using a temp table

Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentagePopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rollingVaccinationCount
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is Not Null
	
select *, (RollingPeopleVaccinated/Population)*100 as percentagevaccinatedPeople
from #PercentagePopulationVaccinated



--Creating Views for later use:
--Saving your view inside your portforlio project.

USE PortfolioProject
GO
CREATE VIEW PercentageVaccinatedview
as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over(partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rollingVaccinationCount
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vacc
on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is Not Null



--EXPLORING THE VIEW TABLE

select *
from PercentageVaccinatedview
