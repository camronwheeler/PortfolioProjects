USE Portfolio_Project;

-- Data retrieved from ourworldindata.org/covid-deaths
SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of the population contracted COVID
SELECT location, date, total_cases, population, (total_cases / population) * 100 as death_percentage
FROM covid_deaths
WHERE location LIKE '%states%'
ORDER BY 1,2;

-- Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(CAST(total_cases as unsigned)) as highest_infection_count, MAX((total_cases / population)) * 100 as percent_population_infected
FROM covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Shows countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as unsigned)) as max_death
FROM covid_deaths
WHERE location NOT IN ('High income', 'Europe', 'North America', 'South America', 'European Union')
GROUP BY location
ORDER BY max_death DESC;

-- Statistics by Continent
SELECT continent, MAX(CAST(total_deaths as unsigned)) as max_death
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_death DESC;

SELECT location, MAX(CAST(total_deaths as unsigned)) as max_death
FROM covid_deaths
WHERE location IN('World', 'Europe', 'North America', 'European Union', 'South America', 'Asia', 'Africa', 'Oceania', 'International')
GROUP BY location
ORDER BY max_death DESC;

-- Showing the continents with the highest death count
SELECT continent, MAX(CAST(total_deaths as unsigned)) as max_death
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_death DESC;

-- Global Statistics
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 as death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date)
as rolling_people_vaccinated
FROM covid_deaths as d JOIN covid_vaccinations as v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date)
as rolling_people_vaccinated
FROM covid_deaths as d JOIN covid_vaccinations as v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated / population) * 100
FROM PopvsVac
ORDER BY location, date;

-- Creating a view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date)
as rolling_people_vaccinated
FROM covid_deaths as d JOIN covid_vaccinations as v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;
