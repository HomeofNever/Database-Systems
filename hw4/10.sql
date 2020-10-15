SELECT 
    mc.castname
FROM
    movies m,
    moviescast mc,
    moviesdirectors md
WHERE
    m.movieid = mc.movieid AND
    md.director = mc.castname AND 
    date_added > '1/1/2019'
EXCEPT
SELECT
    md.director
FROM
    seriescast sc,
    moviesdirectors md
WHERE
    sc.castname = md.director
ORDER BY 
    castname ASC;