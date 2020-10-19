SELECT
    director
FROM
    moviesdirectors
WHERE
    lower(director) NOT LIKE '%steven spielberg%'
GROUP BY
    director
HAVING
    COUNT(*) = (SELECT COUNT(*) FROM moviesdirectors WHERE lower(director) LIKE '%steven spielberg%')
ORDER BY
    director;