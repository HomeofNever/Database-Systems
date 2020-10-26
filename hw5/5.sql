WITH
    t1 AS (
        SELECT
            AVG(imdbrating) as avgafter
        FROM
            movies m INNER JOIN moviesgenres mg ON m.movieid = mg.movieid
        WHERE
            lower(genre) LIKE '%horror%' AND
            year > 2000
    ), 
    t2 AS (
        SELECT
        AVG(imdbrating) as avgbefore
        FROM
            movies m INNER JOIN moviesgenres mg ON m.movieid = mg.movieid
        WHERE
            lower(genre) LIKE '%horror%' AND
            year <  2000)
SELECT
    t2.avgbefore::NUMERIC(5,2),
    t1.avgafter::NUMERIC(5,2),
    (t2.avgbefore)::NUMERIC(5, 2) - (t1.avgafter)::NUMERIC(5, 2) as avgdiff
FROM
    t1, t2;
