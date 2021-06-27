Select *
From Covidsql ..Coviddeaths
Where continent is not null
order by 3,4

--Select *
--From Covidsql..Covidvaccination
--order by 3,4

--Select Data thet we are going to be using

Select location , date, total_cases, total_deaths, population
From Covidsql..Coviddeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--Showing likeliood of dying because of covid in  World Wide

Select location , date, total_cases, total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
From Covidsql..Coviddeaths
Where location like '%India%' and continent is not null
order by 1,2

--Showing likeliood of dying because of covid in  India

Select location , date, total_cases, total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
From Covidsql..Coviddeaths
Where location like  '%India%' and  continent is not null
order by 1,2

--Now we are looking at Total Cases VS  Population in India

Select location , date, total_cases, population, (total_cases/population)*100 as PercentPopulation_infected
From Covidsql..Coviddeaths
Where location like '%India%' and continent is not null
order by 1,2

--Looking at countries which has higest infectious rate

Select location, population, MAX(total_cases) as Infetious_Rate, MAX((total_cases/population))*100 as PercentPopulation_infected
From Covidsql..Coviddeaths
Where continent is not null
Group by location, population
order by PercentPopulation_infected desc

--Showing Countries with higest death Count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covidsql..Coviddeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking down continent wise

Select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
From Covidsql..Coviddeaths
Where continent is not null
Group by  continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covidsql..Coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covidsql..Coviddeaths dea
Join Covidsql..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covidsql..Coviddeaths dea
Join Covidsql..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

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
From Covidsql..Coviddeaths dea
Join Covidsql..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covidsql..Coviddeaths dea
Join Covidsql..Covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
