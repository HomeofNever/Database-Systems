SELECT
	count(*) as nummovies
FROM
	movies
WHERE
	imdbrating is NULL 
	AND rottentomatoes is NULL
    AND (year is NULL OR year > 2015);