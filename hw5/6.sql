WITH
    t1 AS (
        SELECT
            seriesid
        FROM
            seriescountry
        GROUP BY
            seriesid
        HAVING
            COUNT(*) = 1
    )
SELECT
    country,
    title,
    imdbrating
FROM
    series s INNER JOIN seriescountry sc
    ON s.seriesid = sc.seriesid
    INNER JOIN t1
    ON s.seriesid = t1.seriesid
WHERE
    lower(sc.country) IN ('turkey', 'france', 'china', 'india', 'thailand', 'japan') AND
    s.imdbrating >= 7.5
ORDER BY
    country,
    imdbrating,
    title;