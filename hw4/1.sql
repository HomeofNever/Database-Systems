SELECT
	s.title,
	sd.director
FROM
	series s,
    seriesdirectors sd
WHERE
	s.seriesid = sd.seriesid
	AND s.imdbrating < 5 
    AND s.seasons >= 15
ORDER BY
	title,
    director;