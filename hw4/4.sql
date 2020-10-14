SELECT 
	m.movieid AS id,
    m.title,
    'movie' AS streamingtype
FROM
	movies m, 
    moviescountry mc
WHERE
	m.movieid = mc.movieid
    AND lower(mc.country) LIKE '%italy%'
UNION
SELECT 
	s.seriesid AS id,
    s.title,
    'series' AS streamingtype
FROM
	series s, 
    seriescountry sc
WHERE
	s.seriesid = sc.seriesid
    AND lower(sc.country) LIKE '%italy%'
ORDER BY
    title DESC,
    streamingtype DESC;