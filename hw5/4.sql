WITH
    t1 AS (
        SELECT 
            movieid, 
            COUNT(*) as nummovies 
        FROM 
            movieslanguages ml 
        GROUP BY 
            movieid
    ),
    t2 AS (
        SELECT
            MAX(nummovies) as nummax
        FROM
            t1
    )
SELECT
    title,
    nummovies
FROM
    t1
    INNER JOIN t2
    ON t1.nummovies = t2.nummax
    INNER JOIN movies m
    ON t1.movieid = m.movieid
ORDER BY
    title;


