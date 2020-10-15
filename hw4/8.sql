SELECT 
    ml.language,
    MIN(m.imdbrating) as minimdb,
    MAX(m.imdbrating) as maximdb,
    MIN(m.rottentomatoes) as minrotten,
    MAX(m.rottentomatoes) as maxrotten
FROM
    movies m,
    movieslanguages ml
WHERE
    m.movieid = ml.movieid
GROUP BY
    ml.language
HAVING
    COUNT(DISTINCT m.movieid) > 9
ORDER BY
    minimdb, minrotten;