SELECT
    COUNT(*) AS numtuples,
    COUNT(date_added) AS numdate,
    MIN(year) AS minyear,
    MAX(year) AS maxyear,
    AVG(
        SUBSTRING(duration, 1, POSITION(' ' in duration) - 1)::INT
    )::NUMERIC(5, 2) as avgduration,
    avg(imdbrating)::NUMERIC(5, 2) as avgrating
FROM
    movies;