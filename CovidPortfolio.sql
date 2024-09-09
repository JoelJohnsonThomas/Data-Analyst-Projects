-- Select all columns from the CovidDeaths table and order by the 3rd and 4th columns
SELECT * 
FROM PortfolioProject..CovidDeaths where continent is not null
ORDER BY 3, 4;

-- Select all columns from the CovidVaccinations table and order by the 3rd and 4th columns
-- SELECT * 
-- FROM PortfolioProject..CovidVaccinations  
-- ORDER BY 3, 4;

-- Select specific columns from the CovidDeaths table and order by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

-- Calculate the death percentage for locations containing 'states' and order by location and date
SELECT location, date, 
       CAST(total_cases AS FLOAT) AS total_cases, 
       CAST(total_deaths AS FLOAT) AS total_deaths, 
       (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths 
WHERE location LIKE '%states%' 
ORDER BY location, date;

--looking at the total cases vs Population and what percentage of population got covid

SELECT location, date, 
       CAST(total_cases AS FLOAT) AS total_cases, 
       CAST(population AS FLOAT) AS population, 
       CASE 
           WHEN CAST(total_cases AS FLOAT) = 0 THEN 0 
           ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 
       END AS PercentPopulationInfected  
FROM PortfolioProject..CovidDeaths 
WHERE location LIKE '%states%' 
ORDER BY location, date;


--looking at countries with highest infection rate compared to Population

SELECT location, population, 
       MAX(total_cases) AS HighestInfectionCount,
       (CAST(MAX(total_deaths) AS FLOAT) / NULLIF(CAST(MAX(total_cases) AS FLOAT), 0)) * 100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths 
WHERE location LIKE '%states%' 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

--showing countries with highest death count per population

SELECT continent,max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths where continent is not null
group by continent 
order BY TotalDeathCount desc;

--global numbers
select  date, sum(cast(new_deaths as int))--total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

SELECT 
    SUM(CAST(new_cases AS BIGINT)) AS total_cases,
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS BIGINT)) / SUM(CAST(new_cases AS BIGINT))) * 100 AS DeathPercentage 
FROM 
    PortfolioProject..CovidDeaths 
WHERE 
    continent IS NOT NULL 
ORDER BY 
    1, 2;

--Looking at total population vs Vaccinations

WITH VaccinationData AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM 
    VaccinationData
ORDER BY 
    location, date;


--use CTE
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
    -- Order by 2,3
) 

SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM PopvsVac
ORDER BY Location, Date;

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    TRY_CAST(dea.date AS DATETIME) AS date,
    TRY_CAST(dea.population AS NUMERIC) AS population,
    TRY_CAST(vac.new_vaccinations AS NUMERIC) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY TRY_CAST(dea.date AS DATETIME)) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
    AND TRY_CAST(dea.date AS DATETIME) IS NOT NULL
    AND TRY_CAST(dea.population AS NUMERIC) IS NOT NULL
    AND TRY_CAST(vac.new_vaccinations AS NUMERIC) IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated
ORDER BY location, date;




--creating view to store data for later visualizations


create View PercentPopulationVaccinated as 
SELECT 
    dea.continent,
    dea.location,
    TRY_CAST(dea.date AS DATETIME) AS date,
    TRY_CAST(dea.population AS NUMERIC) AS population,
    TRY_CAST(vac.new_vaccinations AS NUMERIC) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY TRY_CAST(dea.date AS DATETIME)) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
