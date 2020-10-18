SELECT 
    *
FROM (
            SELECT
                language,
                COUNT(*) as nummovies
            FROM  
                movies m
                INNER JOIN movieslanguages ml 
                ON m.movieid = ml.movieid
            GROUP BY
                language
            ORDER BY
                nummovies DESC,
                language
            LIMIT 26 OFFSET 14
) AS t
ORDER BY
    nummovies