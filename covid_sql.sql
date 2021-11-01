--TOTAL CASES VS TOTAL DEATHS
SELECT continent, location, SUM(new_cases) total_cases, SUM(convert(numeric, new_deaths)) total_deaths
FROM portfolio..covid_death
where continent is not null
group by location, continent
order by 3 desc

--checking for confirmation
SELECT location, SUM(cast(new_deaths as int)) --total_cases, SUM(convert(numeric, new_deaths)) total_deaths
FROM portfolio..covid_death
where continent is not null
group by location
order by 2 desc


--TOTAL DEATH AS A PERCENT OF TOTAL CASES
SELECT  location,   population, sum(new_cases) total_cases, (sum(cast(new_deaths as int))) total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 Percentage_dead
FROM portfolio..covid_death
WHERE continent is not null 
group by location, population
order by 5 desc


--TOTAL TESTS VS POSITIVE RATES
SELECT location, sum(cast(new_tests as int)) new_tests, sum(convert(float,positive_rate)) positive_rate
FROM portfolio..covid_vaccination
where continent = 'europe'
group by location
order by 1


--PERCENTAGE OF POPULATION INFECTED
SELECT location, population, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, max(total_cases)/population *100 percentage_infected
FROM portfolio..covid_death
WHERE continent is not null
group by location, population
order by 5 desc

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT  continent, location, population, MAX(total_cases) highest_infected, MAX(total_cases/population) *100 max_percentage_infected
FROM portfolio..covid_death
WHERE continent is not null
GROUP BY location, continent, population
order by max_percentage_infected desc


--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION, and TOTAL DEATHS
SELECT  continent, location, population, MAX(total_cases) highest_infected, MAX(total_cases/population) *100 max_percentage_infected, SUM(cast(total_deaths as int)) death_count
FROM portfolio..covid_death
WHERE continent is not null
GROUP BY location, continent, population
order by max_percentage_infected desc


-- COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT  continent, location, population, MAX(cast(total_deaths as int)) Death_count--/population) *100 max_percentage_dead
FROM portfolio..covid_death
WHERE continent is not null
GROUP BY location, continent, population
order by 4 desc


--CONTINENTS DEATH COUNT
SELECT continent, sum(cast(new_deaths as int)) global_death
FROM portfolio..covid_death
WHERE continent is not null
GROUP BY continent--, location
order by 2 desc

--CONTINENTS DEATH COUNT, percent and all cases
SELECT continent, SUM(new_cases) all_cases, sum(cast(new_deaths as int)) global_deaths, sum(convert(int, new_deaths))/sum(new_cases) *100 percentage_fallen
FROM portfolio..covid_death
WHERE continent is not null
GROUP BY continent 
order by 4 desc

--WORLD REPORT
SELECT  SUM(new_cases) all_cases, sum(cast(new_deaths as int)) global_deaths, sum(convert(int, new_deaths))/sum(new_cases) *100 percentage_fallen
FROM portfolio..covid_death
WHERE continent is not null
--GROUP BY continent 
--order by 4 desc


--TOTAL VACCINATION VS POPULATION
SELECT dea.location, dea.date, dea.population,  vax.new_vaccinations,
sum(cast(vax.new_vaccinations as numeric)) OVER (PARTITION BY dea.location order by dea.location, dea.date) rolling_vax, vax.total_vaccinations
FROM portfolio..covid_death dea
JOIN portfolio..covid_vaccination vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
order by location


-- Application of CTE to get the perentage of population vaccinated by country

WITH vaccinated_population (location, date, population, new_vaccinations, rolling_vax)
AS
(
SELECT dea.location, dea.date, dea.population,  vax.new_vaccinations,
sum(cast(vax.new_vaccinations as numeric)) OVER (PARTITION BY dea.location order by dea.location, dea.date) rolling_vax
FROM portfolio..covid_death dea
JOIN portfolio..covid_vaccination vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
) 
SELECT *, (rolling_vax/population)*100 '% Vaccinated'
FROM vaccinated_population
order by '% Vaccinated'


-- IDENTIFY MAXIMUM VACCINATIONS IN EACH COUNTRY
WITH vaccinated_population (location, date, population, new_vaccinations, rolling_vax)
AS
(
SELECT dea.location, dea.date, dea.population,  vax.new_vaccinations,
sum(cast(vax.new_vaccinations as numeric)) OVER (PARTITION BY dea.location order by dea.location, dea.date) rolling_vax
FROM portfolio..covid_death dea
JOIN portfolio..covid_vaccination vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null
)
SELECT location, population, max(rolling_vax)/population*100 '% Vaccinated', SUM(CONVERT(NUMERIC,new_vaccinations)) Total_vaccinations
FROM vaccinated_population
group by location, population
order by '% Vaccinated' DESC



-- THE USE OF A TEMP'orary' TABLE
DROP TABLE IF EXISTS #PERCENTVACCINATED
CREATE TABLE #PERCENTVACCINATED
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vax numeric
)

INSERT INTO #PERCENTVACCINATED
SELECT dea.continent, dea.location, dea.date, dea.population,  vax.new_vaccinations,
sum(cast(vax.new_vaccinations as numeric)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_vax
FROM portfolio..covid_death dea
JOIN portfolio..covid_vaccination vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null

SELECT top 10 location, population, max(rolling_vax/population)*100 '% Vaccinated'
FROM #PERCENTVACCINATED
group by location, population
order by '% Vaccinated' desc


-- CREATE A VIEW FOR VIISUALISATION

CREATE VIEW PERCENTVACINATED AS
SELECT dea.continent, dea.location, dea.date, dea.population,  vax.new_vaccinations,
sum(cast(vax.new_vaccinations as numeric)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as rolling_vax
FROM portfolio..covid_death dea
JOIN portfolio..covid_vaccination vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent is not null




