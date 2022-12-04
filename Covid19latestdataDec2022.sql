use PortfolioProject
select *
from PortfolioProject..['Coviddeaths$']
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['Covidvaccinations$']
----order by 3,4
--select data that we are going to be using

-
select 
Location,date,total_cases,total_deaths,population
from PortfolioProject..['Coviddeaths$']
order by 1,2

-- Looking at Total cases vs total deaths
-- shows the likelihood of dying if you contract covid

select 
Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathrate
from PortfolioProject..['Coviddeaths$']
order by 1,2

-- Looking at death rate per case in Canada
select 
Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where location ='Canada'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid


select 
Location,date,total_cases,population, (total_cases/population)*100 as covidrate
from PortfolioProject..['Coviddeaths$']
where location ='Canada'
order by 1,2

--looking for what country had the highest infection rate, compared with population

select 
Location,MAX(total_cases) as HighestInfectionCount,population, MAX( (total_cases/population))*100 as covidrate
from PortfolioProject..['Coviddeaths$']
Group by Location, population
order by covidrate desc

--showing the countries with the highest death count per population

select 
Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by Location
order by TotalDeathCount desc

-- showing the continents with the highest death count

select 
continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc

-- to get a clearer picture of the covid deaths, the below query would help

select 
location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Coviddeaths$']
where continent is null
Group by location
order by TotalDeathCount desc

--showing the continents with the highest death count
select 
continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers

select 
date,SUM(new_cases)--,total_deaths, (total_deaths/total_cases)*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by date
order by 1,2

select 
date,SUM(new_cases)--,SUM (cast(new_deaths as int))--, (total_deaths/total_cases)*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by date
order by 1,2

select 
date,SUM(new_cases)as totalcases,SUM (cast(new_deaths as int))as totaldeaths, (SUM (cast(new_deaths as int))/SUM(new_cases))*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by date
order by 1,2

-- to get the latest global figure

select 
SUM(new_cases)as totalcases,SUM (cast(new_deaths as int))as totaldeaths, (SUM (cast(new_deaths as int))/SUM(new_cases))*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where continent is not null
order by 1,2

-- Linking the 2 tables

select *
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date

-- looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--to get total daily vaccinations per location  

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingvaccinationCount
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Looking at total populations vs vaccinations

--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingvaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingvaccinationCount
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3
select * ,(RollingvaccinationCount/population)*100 
from #PercentPopulationVaccinated

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingvaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingvaccinationCount
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
order by 2,3
select * ,(RollingvaccinationCount/population)*100 
from #PercentPopulationVaccinated

--creating view to store for later visualization

Create view PercentVaccinatedPopulation as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location Order by dea.location, dea.date) as RollingvaccinationCount
from PortfolioProject..['Coviddeaths$']  dea
join PortfolioProject..['Covidvaccinations$']  vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Create view Totaldeathpercontinent as
select 
continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['Coviddeaths$']
where continent is not null
Group by continent
--order by TotalDeathCount desc

create view deathratepercaseCanada as
select 
Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathrate
from PortfolioProject..['Coviddeaths$']
where location ='Canada'
--order by 1,2







