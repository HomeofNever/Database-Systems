SELECT
    director
FROM
    moviesdirectors
GROUP BY
    director
HAVING
    COUNT(*) = (SELECT COUNT(*) FROM moviesdirectors WHERE lower(director) LIKE '%steven spielberg%')
ORDER BY
    director;