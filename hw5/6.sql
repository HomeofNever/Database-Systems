SELECT
    country,
    title,
    imdbrating
FROM
    series s INNER JOIN seriescountry sc
    ON s.seriesid = sc.seriesid
WHERE
    s.seriesid IN   (SELECT
                                    seriesid
                                FROM
                                    seriescountry
                                GROUP BY
                                    seriesid
                                HAVING
                                    COUNT(*) = 1) AND
    lower(sc.country) IN ('turkey', 'france', 'china', 'india', 'thailand', 'japan') AND
    s.imdbrating >= 7.5
ORDER BY
    country,
    imdbrating,
    title;