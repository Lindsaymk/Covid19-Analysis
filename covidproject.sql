

select *
from dbo.CovidDeaths$

-- selecting data we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not NULL
order by 1,2

-- checking Total Cases vs Total Deaths
-- shows likelihood of dying after contracting covid 19
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not NULL
order by 1,2

-- checking total cases vs population
-- shows what percentage of the population contracted covid 19
select Location, date, Population, total_cases, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths$
where Location like '%kenya%'
and continent is not NULL
order by 1,2

--checking countries with the highest infection rate compared to population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectedPercentage
from CovidDeaths$
where continent is not NULL
group by Location, population
order by HighestInfectedPercentage desc

-- showing countries with the highest death count per population
select Location, max(cast(Total_deaths as int)) as HighestDeathCount
from CovidDeaths$
where continent is not NULL
group by Location, population
order by HighestDeathCount desc

--breaking it down into continents
select location, max(cast(Total_deaths as int)) as HighestDeathCount
from CovidDeaths$
where continent is NULL
group by location
order by HighestDeathCount desc

--showing global numbers by dates
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from CovidDeaths$
where continent is not NULL
group by date
order by 1,2

--showing total global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
from CovidDeaths$
where continent is not NULL

--joining the tables
select * 
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

--checking total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated

from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
from PopvsVac

--temp table
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated

--making a correction in the temp table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated

--creating view for visualisations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
















