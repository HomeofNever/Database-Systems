SELECT
	count(*) as nummovies
FROM
	movies
WHERE
	(imdbrating is NULL 
    OR rottentomatoes is NULL)
    AND (year is NULL or year > 2015);