CREATE TABLE dbo.Population (
    region_name NVARCHAR(100) NOT NULL,
    country_name NVARCHAR(100) NOT NULL,
    reporting_year INT NOT NULL,
    headcount FLOAT,
    poverty_gap FLOAT,
    poverty_severity FLOAT,
    mean FLOAT,
    median FLOAT,
    gini FLOAT,
    decile1 FLOAT,
    decile10 FLOAT,
);

select * from dbo.Population;



SELECT region_name, AVG(headcount) AS avg_headcount
FROM dbo.Population
GROUP BY region_name;

SELECT country_name, MAX(mean) AS max_mean_income
FROM dbo.Population
GROUP BY country_name;



SELECT reporting_year, SUM(poverty_gap) AS total_poverty_gap
FROM dbo.Population
GROUP BY reporting_year
ORDER BY reporting_year;


SELECT region_name, MIN(gini) AS min_gini, MAX(gini) AS max_gini
FROM dbo.Population
GROUP BY region_name;



SELECT reporting_year, COUNT(*) AS high_poverty_countries
FROM dbo.Population
WHERE headcount > 0.8
GROUP BY reporting_year
ORDER BY reporting_year;

