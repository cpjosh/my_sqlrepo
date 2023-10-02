SELECT TOP(10) * FROM project_covid.dbo.covid_deaths ORDER BY 3,4

SELECT * FROM project_covid..covid_vax ORDER BY 3,4


SELECT location,
	SUM(CAST(new_vaccinations as FLOAT)) as total_vaccination
FROM project_covid..covid_vax 
WHERE (new_vaccinations is not NULL) and (continent is not NULL)
GROUP BY location
ORDER BY 1

-- firstly, checking how many people were affected by Covind in this recorded period
-- the number is presuembly higher, it is rough estimate

SELECT SUM(cases_per_continent) as total_covid_cases

FROM (SELECT MAX(total_cases) as cases_per_continent,
		continent
FROM project_covid.dbo.covid_deaths
WHERE continent is not NULL
GROUP BY continent)

-- it seems there could be cases of multiple infections by virus so , we can rather say ther were more than 68.5 billion covid cases across the world

------------------------------------------------------------------------

-- cases per continent

SELECT MAX(total_cases) as cases_per_continent,
		continent
FROM project_covid.dbo.covid_deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY cases_per_continent DESC


-----------------------------------------------------------------------

SELECT total_cases,
		continent,
		location
FROM project_covid.dbo.covid_deaths

---------------------------------------------------------------------------

-- cases per country 

SELECT MAX(total_cases) as cases_per_country,
		location
FROM project_covid.dbo.covid_deaths
WHERE total_cases is not Null
GROUP BY location
ORDER BY cases_per_country DESC


----------------------------------------------------------------
-- selecting data from nepal

SELECT MAX(total_cases) as total_cases_in_nepal			
FROM project_covid.dbo.covid_deaths
WHERE location = 'Nepal'

---------------------------------------------------------------

-- total deaths by continent 

SELECT MAX(CAST(total_deaths AS int)) as deaths,
		location
FROM project_covid.dbo.covid_deaths
WHERE continent is NULL
GROUP BY location
ORDER BY deaths DESC


-- From here I am going to follow the instructer 
-- First, selecting the required columns from the table

SELECT location, date, total_cases, new_cases, total_deaths,population

FROM project_covid..covid_deaths

ORDER BY 1, 2


-- total cases vs total deaths (--number of deaths per total cases)

SELECT TOP(1000) location, date, total_cases, new_cases, total_deaths,population, (total_deaths/total_cases)*100 as deaths_percentage

FROM project_covid..covid_deaths

WHERE location = 'India'

ORDER BY 1, 2

-- this shows likelyhood of dying if contracted COVID in INDIA

--------------------------------------------------------------------------------

--looking at total cases per population of country

SELECT location, date, total_cases, new_cases, total_deaths,population, ((total_cases/population)*100) as likely_get_covid

FROM project_covid..covid_deaths

WHERE location = 'India'

ORDER BY 1, 2

--likelyhood of getting covid in India, this is a daily analysis

-----------------------------------------------------------------------------------------

-- lets sum total cases against the populataion, infection rate

SELECT  location,
		MAX(total_cases) as cases,
		AVG(population) as total_population, (MAX(total_cases)/AVG(population))*100 as affected_population_percentage

FROM project_covid..covid_deaths

GROUP BY location

ORDER BY affected_population_percentage DESC


-------------------------------------------------------------

--checking_1
SELECT AVG(population) as total_population

FROM project_covid..covid_deaths

WHERE location = 'India'

--checking_2

SELECT MAX(total_cases) as total_cases_india

FROM project_covid..covid_deaths

WHERE location = 'India'

-------------------------------------------------------------------------------

--showing countries with highest death count per population

SELECT MAX(CAST(total_deaths AS int)) as deaths,
		location
FROM project_covid.dbo.covid_deaths
WHERE continent is not NULL    -- to exclude the inclusion of continent placed in location column
GROUP BY location
ORDER BY deaths DESC

------------------------------------------------------------------------------------
-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM project_covid..covid_deaths
where continent is not NULL
GROUP BY date
ORDER BY 1,2

-----------------------------------------------------------------------------------
-- total it out

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM project_covid..covid_deaths
where continent is not NULL
--GROUP BY date
ORDER BY 1,2

-----------------------------------------------------------------------------------

-- JOINS

SELECT *
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date

-----------------------------------------------------------------------------------

-- total population vs vaccination numbers

SELECT dea.location, AVG(dea.population) as population, SUM(CAST(vac.new_vaccinations as int)) as vaccination
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL and dea.new_vaccinations is not NULL
GROUP BY dea.location
ORDER BY location

-------------------------------------------------------------------------------

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccine
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE (dea.continent is not NULL) and (dea.new_vaccinations is not NULL)
ORDER BY 2,3


-------------------------------------------------------------------------------------

--USE CTE
WITH pplvsvax(location, population, vaccination)
as
(
SELECT dea.location, AVG(dea.population) as population, SUM(CAST(vac.new_vaccinations as int)) as vaccination
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL and dea.new_vaccinations is not NULL
GROUP BY dea.location
--ORDER BY location
)
SELECT *, (vaccination/population)*100 as vaccinatio_percentage
FROM pplvsvax
ORDER BY location


-----------------------------------------------------------------------------------
--Temp Table
DROP TABLE IF EXISTS #percentpopnvaccin
CREATE TABLE #percentpopnvaccin
(
location nvarchar(255),
population numeric,
vaccination numeric,
)
INSERT INTO #percentpopnvaccin
SELECT dea.location, AVG(dea.population) as population, SUM(CAST(vac.new_vaccinations as int)) as vaccination
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL and dea.new_vaccinations is not NULL
GROUP BY dea.location

SELECT *, (vaccination/population)*100 as vaccinatio_percentage
FROM #percentpopnvaccin
ORDER BY location

--------------------------------------------------------------------------------

-- createing VIEW

CREATE VIEW percentpopnvaccin as
SELECT dea.location, AVG(dea.population) as population, SUM(CAST(vac.new_vaccinations as int)) as vaccination
FROM project_covid..covid_deaths dea
JOIN project_covid..covid_vax as vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL and dea.new_vaccinations is not NULL
GROUP BY dea.location
