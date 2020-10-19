SELECT
    title,
    nummovies
FROM
    movies m
    INNER JOIN (SELECT movieid, COUNT(*) as nummovies FROM movieslanguages ml GROUP BY movieid) AS t1
    ON m.movieid = t1.movieid
WHERE
    nummovies >= ALL (
                                                SELECT
                                                    COUNT(*)
                                                FROM
                                                    movieslanguages
                                                GROUP BY
                                                    movieid
                                            )
ORDER BY
    title;


