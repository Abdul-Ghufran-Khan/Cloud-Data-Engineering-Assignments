CREATE TABLE netflix_titles (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(300),
    director VARCHAR(500),
    cast VARCHAR(1000),
    country VARCHAR(200),
    date_added VARCHAR(50),
    release_year VARCHAR(10),
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(500),
    description VARCHAR(500)
);


SELECT COUNT(*) FROM netflix_titles;
SELECT TOP 10 * FROM netflix_titles;




CREATE TABLE netflix_clean (
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(20),
    title VARCHAR(300),
    director VARCHAR(500),
    cast VARCHAR(MAX),
    country VARCHAR(200),
    date_added DATE,
    release_year INT,
    rating VARCHAR(20),
    duration_value INT,
    duration_unit VARCHAR(20),
    listed_in VARCHAR(500),
    description VARCHAR(MAX)
);



INSERT INTO netflix_clean (
    show_id, type, title, director, cast, country,
    date_added, release_year, rating,
    duration_value, duration_unit,
    listed_in, description
)
SELECT
    show_id,
    type,
    title,
    NULLIF(director, ''),
    NULLIF(cast, ''),
    NULLIF(country, ''),

    -- Convert date_added
    TRY_CONVERT(DATE, date_added, 106),

    -- Convert release_year
    TRY_CAST(release_year AS INT),

    rating,

    -- Extract duration number
    TRY_CAST(LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) AS INT),

    -- Extract duration unit (min / Season / Seasons)
    LTRIM(SUBSTRING(duration, CHARINDEX(' ', duration + ' ') + 1, 20)),

    listed_in,
    description
FROM netflix_titles;


UPDATE netflix_clean
SET duration_unit = 'Season'
WHERE duration_unit = 'Seasons';


UPDATE netflix_clean
SET country = LEFT(country, CHARINDEX(',', country + ',') - 1)
WHERE country LIKE '%,%';



SELECT * FROM netflix_clean;



-- Movies vs TV Shows
SELECT type, COUNT(*) FROM netflix_clean GROUP BY type;

-- Titles by year
SELECT release_year, COUNT(*) 
FROM netflix_clean
GROUP BY release_year
ORDER BY release_year;

-- Longest movies
SELECT title, duration_value
FROM netflix_clean
WHERE type = 'Movie'
ORDER BY duration_value DESC;





