-- TOTAL DEATHS VS. TOTAL CASES
SELECT location,date, total_cases,total_deaths, 
convert(float,total_deaths) / convert(float,total_cases) *100 as DeathPercentage
FROM dbo.DEATHS 
WHERE location like '%TURKEY%' 
ORDER BY 1,2


-- TOTAL CASES VS. POPULATÝON 
SELECT location, date, total_cases, population,
CONVERT(FLOAT, total_cases) / CONVERT(float, population) * 100 AS PercentPopulationInfected
FROM dbo.DEATHS
WHERE location like '%TURKEY%'
ORDER BY 1,2


-- Looking at Countries Highest Inflection Rate compared to Population
SELECT location, population, MAX(convert(float,total_cases)) AS Highest_Infection_Count, 
MAX(CONVERT(float, total_cases)) / MAX(CONVERT(float,population)) * 100	AS Percent_Population_Ýnfected
FROM dbo.DEATHS
GROUP BY location, population
ORDER BY 4 desc


--Showing Countries with Highest Death Count per Population 
SELECT location, MAX(convert(float,total_deaths)) AS Higest_Deaths_Count
FROM dbo.DEATHS
where continent is not null
GROUP BY location
order by 2 desc


-- Let's break down by continent
SELECT continent, max(cast(total_deaths as float)) AS Total_Deaths
FROM dbo.DEATHS
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers
SELECT 
 sum(CONVERT(FLOAT,new_cases)) as Total_Cases, sum(CONVERT(FLOAT,new_deaths)) as Total_Deaths,
sum(CONVERT(FLOAT,new_deaths)) / sum(CONVERT(FLOAT,new_cases)) *100 as DatePercentage
FROM dbo.DEATHS
where continent is not null
--GROUP BY date
order by 1


-- TOTAL POPULATÝON VS VACCÝNATÝONS
SELECT D.continent, D.location, D.date , population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as float)) OVER (Partition by D.location order by D.location, D.Date) AS Rolling_People_Vaccinated
FROM dbo.DEATHS AS D
JOIN dbo.VACCÝNATÝONS AS V ON D.location = V.location and D.date = V.date
where D.continent is not null
ORDER BY 2,3


With TMP (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT D.continent, D.location, D.date , population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as float)) OVER (Partition by D.location order by D.location, D.Date) AS Rolling_People_Vaccinated

FROM dbo.DEATHS AS D
JOIN dbo.VACCÝNATÝONS AS V ON D.location = V.location and D.date = V.date
where D.continent is not null
)

SELECT *, (Rolling_People_Vaccinated) / (population) * 100
FROM TMP
order by 2,3

SET ANSI_WARNINGS on
GO

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulatinVaccinated
CREATE TABLE #PercentPopulatinVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
insert into #PercentPopulatinVaccinated
SELECT D.continent, D.location, D.date , population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as float)) OVER (Partition by D.location order by D.location, D.Date) AS Rolling_People_Vaccinated

FROM dbo.DEATHS AS D
JOIN dbo.VACCÝNATÝONS AS V ON D.location = V.location and D.date = V.date
--where D.continent is not null

SELECT *, (Rolling_People_Vaccinated) / (population) * 100
FROM #PercentPopulatinVaccinated



-- Let's Create a view For Visualization 
Create View PercentPopulatinVaccinated AS 
SELECT D.continent, D.location, D.date , population, V.new_vaccinations, 
SUM(cast(V.new_vaccinations as float)) OVER (Partition by D.location order by D.location, D.Date) AS Rolling_People_Vaccinated
FROM dbo.DEATHS AS D
JOIN dbo.VACCÝNATÝONS AS V ON D.location = V.location and D.date = V.date
where D.continent is not null


Select * FROM PercentPopulatinVaccinated
