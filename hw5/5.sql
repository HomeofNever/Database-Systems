SELECT
    b.avgbefore::NUMERIC(5,2),
    a.avgafter::NUMERIC(5,2),
    ABS(b.avgbefore - a.avgafter)::NUMERIC(5, 2) as avgdiff
FROM
    (SELECT
        AVG(imdbrating) as avgafter
    FROM
        movies m INNER JOIN moviesgenres mg ON m.movieid = mg.movieid
    WHERE
        lower(genre) LIKE '%horror%' AND
        year > 2000) AS a,
    (SELECT
        AVG(imdbrating) as avgbefore
    FROM
        movies m INNER JOIN moviesgenres mg ON m.movieid = mg.movieid
    WHERE
        lower(genre) LIKE '%horror%' AND
        year <  2000) AS b;