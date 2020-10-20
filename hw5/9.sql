SELECT
    mc.castname
FROM
    moviescast mc INNER JOIN movies m 
    ON mc.movieid = m.movieid
    INNER JOIN moviesdirectors md 
    ON md.movieid = m.movieid
GROUP BY
    mc.castname, md.director
HAVING
    COUNT(*) > 2
EXCEPT
SELECT
    mc.castname
FROM
    moviescast mc INNER JOIN moviesdirectors md 
    ON mc.castname = md.director
ORDER BY
    castname;