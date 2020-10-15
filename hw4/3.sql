SELECT 
	m.title, 
    md.director
FROM
	movies m,
    movieslanguages ml,
    moviesdirectors md,
    moviesgenres mg
WHERE
	m.movieid = ml.movieid
    AND m.movieid = md.movieid
    AND m.movieid = mg.movieid
	AND m.imdbrating >= 8
    AND (
        lower(mg.genre) LIKE '%action%'
        OR lower(mg.genre) LIKE '%sci-fi%'
        OR lower(mg.genre) LIKE '%adventure%'
        OR lower(mg.genre) LIKE '%drama%'
    )
GROUP BY
 	m.title, 
    md.director
HAVING
    COUNT(DISTINCT ml.language) > 1
INTERSECT
SELECT 
    m.title, 
    md.director
FROM
    movies m,
    moviesdirectors md,
    movieslanguages ml
WHERE 
	m.movieid = ml.movieid
    AND m.movieid = md.movieid
    AND lower(ml.language) LIKE '%english%';
