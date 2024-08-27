Select *
 from PortfolioProject..CovidDeaths$
 order by 3,4 desc
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 3,4 desc
-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,CONCAT(CAST(Round((total_deaths/total_cases)*100,2) AS VARCHAR(10)),'%') as 'Death percentage'
from PortfolioProject..CovidDeaths$
Where(total_cases is not null and total_deaths is not null)
Order by 1,2

--Looking at the Total Cases vs Population
select Location,date,total_cases,population,CONCAT(CAST(Round((total_cases/population)*100,2) AS VARCHAR(10)),'%') as 'Case percentage'
from PortfolioProject..CovidDeaths$
Where (total_cases is not null and total_deaths is not null)
Order by 1,2

--Looking at Countries with Highest Infection Rate per Population
select location,max(total_cases) as HighestInfectionCount,population,CONCAT(CAST(Round(max((total_cases /population)*100),2) AS VARCHAR(10)),'%') as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
Where (total_cases is not null and population is not null)
Group by location,population
Order by max((total_cases /population)*100) desc

--Showing countries with the Highest Death Cont per Population
select location,sum(Cast( total_deaths as int)) as TotlaDeaths
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotlaDeaths desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


select continent,max(Cast( total_deaths as int)) as TotlaDeaths
from PortfolioProject..CovidDeaths$
where continent is not  null
group by continent
order by TotlaDeaths desc
--GLOBAL NUMBERS

select date,sum(new_cases) as GlobalCases,Sum(cast(new_deaths as int) ) as GlobalDeaths,concat(Cast(Round((Sum(cast(new_deaths as int) ) /sum(new_cases))*100,2) as varchar),'%') as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--looking at total Population vs Vaccinations
select CvD.continent,CvD.location,CvD.date,CvD.population,CVV.new_vaccinations
from PortfolioProject..CovidDeaths$ as CvD
join PortfolioProject..CovidVaccinations$ as CVV
on CVV.date = CvD.date and CVV.location = CvD.location
where CvD.continent is not null and CVV.new_vaccinations is not null
order by 2,3
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Using CTE to perform Calculation on Partition By in previous query

with sum_vaccination(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as  (
select CvD.continent,CvD.location,CvD.date,CvD.population,CVV.new_vaccinations,sum(convert(int,CVV.new_vaccinations)) over (partition by CVV.Location order by CVV.location,CVV.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as CvD
join PortfolioProject..CovidVaccinations$ as CVV
on CVV.date = CvD.date and CVV.location = CvD.location
where CvD.continent is not null and CVV.new_vaccinations is not null
)select *,CONCAT(CAST(Round(((RollingPeopleVaccinated/population)*100),2) as varchar),'%') AS VaccinationPercentage 
from sum_vaccination
order by continent,location

--TEMP TABLE
Drop table if exists #sum_vaccination
Create table #sum_vaccination (
continent nvarchar(50),
location nvarchar (50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into #sum_vaccination 
select CvD.continent,CvD.location,CvD.date,CvD.population,CVV.new_vaccinations,sum(convert(int,CVV.new_vaccinations)) over (partition by CVV.Location order by CVV.location,CVV.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as CvD
join PortfolioProject..CovidVaccinations$ as CVV
on CVV.date = CvD.date and CVV.location = CvD.location
where CvD.continent is not null and CVV.new_vaccinations is not null
order by 1,2

select *,CONCAT(CAST(ROUND((RollingPeopleVaccinated / CAST(population AS FLOAT) * 100),2) AS VARCHAR),'%') AS VaccinationPercentage
from #sum_vaccination


--Creating Vieww to sotre date for later visaulizations
create view PercentPoplationVaccinated as 
select CvD.continent,CvD.location,CvD.date,CvD.population,CVV.new_vaccinations,sum(convert(int,CVV.new_vaccinations)) over (partition by CVV.Location order by CVV.location,CVV.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as CvD
join PortfolioProject..CovidVaccinations$ as CVV
on CVV.date = CvD.date and CVV.location = CvD.location
where CvD.continent is not null and CVV.new_vaccinations is not null

select * 
from PercentPoplationVaccinated
order by 2,3