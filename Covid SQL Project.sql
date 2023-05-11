-- all the data 
Select *
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4


--relevant data
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 1,2

--% Death in world
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--% Death in Israel
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float) /cast(total_cases as float))*100 as "Death % of Infected people"
From PortfolioProject..CovidDeaths
where location	Like '%Israel%'
and continent is not Null
Order by 1,2

--Infection% in Israel
Select Location, date,	population, total_cases, (total_cases/population)*100 as '% Infected  of Total Population'
From PortfolioProject..CovidDeaths
where location	Like '%Israel%'
and continent is not Null
Order by 1,2

--Sort Countries with Highest Infected %
Select Location, population,date, max(total_cases) as 'Highest Infection Count', max((total_cases/population))*100 as 'Precent Of Population Infected'
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by location,population,date
Order by 'Precent Of Population Infected' desc

--Sort Countries with Highest Death %
Select Location, population, max(total_deaths) as 'Highest Death Count', max((total_deaths/population))*100 as 'Precent Of Population Died'
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by location,population
Order by 'Precent Of Population Died' desc
 
 -- Sort Countries with Highest Death Count
Select Location, MAX(cast(total_deaths as numeric)) as DeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by location
Order by DeathCount desc

 -- Sort Continents with Highest Death Count
Select location, MAX(cast(total_deaths as numeric)) as DeathCount
From PortfolioProject..CovidDeaths
Where continent is Null and location in ('Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania')
Group by location
Order by DeathCount desc


 --Global Infected Count Death Count and Death % of Infected
Select  Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths)/Sum(new_cases))*100 as Death_Precentage
From PortfolioProject..CovidDeaths
where location	Like '%Israel%' and continent is not Null
Group by date
Having  Sum(new_cases) <> 0
order by date

 --Global Infected Count Death Count and Death % of Infected ,This Time the Counts is accroding to Dates (Avoiding dividing by 0 Error with Having) 
Select  date, Sum(new_cases) as TotalCases, Sum(new_deaths) as TotalDeaths, (Sum(new_deaths)/Sum(new_cases))*100 as Death_Precentage
From PortfolioProject..CovidDeaths
--where location	Like '%Israel%'
Where continent is not Null
Group by date
Having  Sum(new_cases) <> 0
order by date

 --all Data
Select *
From PortfolioProject..CovidVaccinations

 -- All Data joined and accroding to Dates TotalVaccinations displayed
Select Vaccine.date,Sum(cast(new_vaccinations as numeric)) as TotalVaccinations
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null
Group by Vaccine.date
order by date

 -- Global TotalVaccinations
Select Sum(cast(new_vaccinations as numeric)) as TotalVaccinations
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null

-- Relevant Data and Gradually Summing New Vaccination accroding to Date and of course location 
Select	Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
Sum(cast(Vaccine.new_vaccinations as numeric)) Over (Partition by Death.Location Order by Death.Location, Death.date) as TotalVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null
Order by 2,3

 --CTE
 --In Order to use TotalVaccinated Later to Calculate Vaccinated %
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated)
as
(
Select	Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
Sum(cast(Vaccine.new_vaccinations as numeric)) Over (Partition by Death.Location Order by Death.Location, Death.date) as TotalVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null
--Order by 2,3
)
Select * ,(TotalVaccinated/Population)*100 as VaccinatedPrecentage
From PopvsVac

 --CTE
 --in Order to use TotalVaccinated to Sort Countries by Vaccinated %

With PopvsVacLocal(Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated)
as
(
Select	Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
Sum(cast(Vaccine.new_vaccinations as numeric)) Over (Partition by Death.Location Order by Death.Location, Death.date) as TotalVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null
--Order by 2,3
)
Select Location,Population,Max((TotalVaccinated/Population)*100) as VaccinatedPrecentage
From PopvsVacLocal
Group by Location,Population
order by VaccinatedPrecentage desc

 --Creating View to VisualizE

Create View VaccinatedPrecentage as
Select	Death.continent, Death.location, Death.date, Death.population, Vaccine.new_vaccinations, 
Sum(cast(Vaccine.new_vaccinations as bigint)) Over (Partition by Death.Location Order by Death.Location, Death.date) as TotalVaccinated
From PortfolioProject..CovidDeaths Death
Join PortfolioProject..CovidVaccinations Vaccine
On Death.location = Vaccine.location and Death.date = Vaccine.date
Where Vaccine.continent is not Null
--Order by 2,3

