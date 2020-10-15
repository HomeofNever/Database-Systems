SELECT 
	mc.movieid AS id,
    m.title,
    'movie' AS streamingtype
FROM
	movies m, 
    moviescountry mc
WHERE
	m.movieid IN (
        SELECT mc.movieid
        FROM moviescountry mc
        GROUP BY
            mc.movieid
        HAVING COUNT(mc.country) < 2
    ) AND
    m.movieid = mc.movieid AND
    lower(mc.country) LIKE '%italy%'
UNION
SELECT 
	s.seriesid AS id,
    s.title,
    'series' AS streamingtype
FROM
	series s, 
    seriescountry sc
WHERE
        s.seriesid IN (
        SELECT sc.seriesid
        FROM seriescountry sc
        GROUP BY
            sc.seriesid
        HAVING COUNT(sc.country) < 2
    ) AND
	s.seriesid = sc.seriesid AND
    lower(sc.country) LIKE '%italy%'
ORDER BY
    title DESC,
    streamingtype DESC;