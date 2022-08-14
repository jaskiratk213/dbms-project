Select * 
from project1..['covid deaths$']
where continent is not null
order by 3,4

select location,date, total_cases, new_cases, total_deaths, population
from project1..['covid deaths$']
where continent is not null
order by 1,2

select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from project1..['covid deaths$']
where location like '%states%'
and continent is not null
order by 1,2

select location,date, total_cases, population,(total_cases/population)*100 as Percentage_affected
from project1..['covid deaths$']
where continent is not null
order by 1,2

select location,population, Max(total_cases) as Highest_infection_count ,Max((total_cases/population))*100 as Percentage_affected
from project1..['covid deaths$']
where continent is not null
group by location, population
order by  Percentage_affected desc

select location,Max(cast(total_deaths as int)) as TotalDeathCount
from project1..['covid deaths$']
where continent is not null
group by location
order by TotalDeathCount desc

select location,Max(cast(total_deaths as int)) as TotalDeathCount
from project1..['covid deaths$']
where continent is null
group by location
order by TotalDeathCount desc

select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from project1..['covid deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc


select date, Sum(new_cases) as new_cases_per_day, sum(cast(new_deaths as int)) as new_deaths_per_day, sum(cast(new_deaths as int))/sum(new_cases) as Globaldeathpercentage
from project1..['covid deaths$']

where continent is not null
group by date
order by 1,2

select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as Globaldeathpercentage
from project1..['covid deaths$']
where continent is not null

order by 1,2

-- looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) 
as RollingpeopleVaccinated
from project1..['covid deaths$'] dea
join project1..['covid vaccinations$'] vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	order by 2,3




--using a CTE
with popvsvac (continent, location, date, population, new_vaccinations, RollingpeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) 
as RollingpeopleVaccinated
from project1..['covid deaths$'] dea
join project1..['covid vaccinations$'] vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingpeopleVaccinated/population)*100
from popvsvac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..['covid deaths$'] dea
Join project1..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




Create View xyz as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project1..['covid deaths$'] dea
Join project1..['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 