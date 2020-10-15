SELECT
 mc.castname,
 COUNT(DISTINCT m) as nummovies,
 COUNT(DISTINCT s) as numseries
FROM
    movies m,
    series s,
    moviescast mc,
    seriescast sc,
    seriesgenres sg,
    moviesgenres mg
WHERE
    mc.movieid = m.movieid AND
    s.seriesid = sc.seriesid AND
    s.seriesid = sg.seriesid AND
    m.movieid = mg.movieid AND
    mc.castname = sc.castname AND
    sg.genre = mg.genre AND
    (
        lower(mg.genre) LIKE '%mystery%' OR
        lower(mg.genre) LIKE '%thriller%'
    ) AND (
        lower(sg.genre) LIKE '%mystery%' OR
        lower(sg.genre) LIKE '%thriller%'
    )
GROUP BY
    mc.castname
ORDER BY
    nummovies,
    numseries,
    castname;