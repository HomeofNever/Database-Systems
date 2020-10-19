SELECT
    sc.country,
    s.title,
    s.imdbrating
FROM
    series s INNER JOIN seriescountry sc
    ON s.seriesid = sc.seriesid
    INNER JOIN (SELECT
                                country, 
                                MAX(imdbrating) AS imdbrating
                            FROM
                                series s INNER JOIN seriescountry sc 
                                ON s.seriesid = sc.seriesid
                                INNER JOIN (SELECT
                                                                seriesid
                                                            FROM
                                                                seriescountry
                                                            GROUP BY
                                                                seriesid
                                                            HAVING
                                                                COUNT(*) = 1
                                                            UNION
                                                            SELECT
                                                                seriesid
                                                            FROM
                                                                seriescountry
                                                            WHERE
                                                                lower(country) LIKE '%united states%') AS t1
                                ON s.seriesid = t1.seriesid
                            GROUP BY
                                country) AS t2
    ON sc.country = t2.country AND s.imdbrating = t2.imdbrating
ORDER BY
    country,
    title;