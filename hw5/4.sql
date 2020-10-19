SELECT
    title,
    nummovies
FROM
    movies m
    INNER JOIN (SELECT movieid, COUNT(*) as nummovies FROM movieslanguages ml GROUP BY movieid) AS t1
    ON m.movieid = t1.movieid
WHERE
    nummovies = (SELECT 
                                    MAX(count) 
                                  FROM (
                                                SELECT
                                                    COUNT(*)
                                                FROM
                                                    movieslanguages
                                                GROUP BY
                                                    movieid
                                            )  AS t2)
ORDER BY
    title;


