--select * 
--from dbo.covidVaccination
--order by 3,4

select * 
from dbo.covidDeath
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from dbo.covidDeath
order by 1,2

--looking at total cases vs total death
--shows likelihood of dying if you contract covid
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percetage
from dbo.covidDeath
where location like'%states%' and continent is not null
order by 1,2

--looking at total cases vs population
select location,date,total_cases,population,(total_deaths/population)*100 as Death_percetage
from dbo.covidDeath
where location like'%states%' and continent is not null
order by 1,2

--looking at countries with highest infection rate compared  to population
select location,population,max(total_cases)as highestinfectioncount,max((total_cases/population))*100 as PercentPopulationInfected
from dbo.covidDeath
--where location like'%states%' and continent is not null
Group by location,population 
order by PercentPopulationInfected desc

--showing  countries with highest death count per  population
select location,max(cast(total_deaths as int))as totalDeathCount
from dbo.covidDeath
where continent is not null
Group by location
order by totalDeathCount desc
--lets break down into continent

select location,max(cast(total_deaths as int))as totalDeathCount
from dbo.covidDeath
where continent is null
Group by location
order by totalDeathCount desc




--global numbers
select date,sum(new_cases) as NewCasesCount,sum(cast(new_deaths as int))as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.covidDeath
where continent is not null
group by date
order by 1,2


-- location  at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
from dbo.covidDeath dea
join dbo.covidVaccination vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--withcte
with PopvsVac (continent,location,date,population,NewVaccinations,RollingPeopleVaccination)
as(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
from dbo.covidDeath dea
join dbo.covidVaccination vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccination/population)*100 from PopvsVac



drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
from dbo.covidDeath dea
join dbo.covidVaccination vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select * from #PercentPopulationVaccinated

Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccination
from dbo.covidDeath dea
join dbo.covidVaccination vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null