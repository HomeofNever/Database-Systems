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
        EXCEPT
        SELECT
            seriesid
        FROM
            seriescountry
        WHERE
            lower(country) LIKE '%united states%'),
    t2 AS (
            SELECT
                country, 
                MAX(imdbrating) AS imdbrating
            FROM
                series s INNER JOIN t1
                ON s.seriesid = t1.seriesid 
                INNER JOIN seriescountry sc 
                ON s.seriesid = sc.seriesid
            GROUP BY
                country
            ) 
SELECT
    sc.country,
    s.title,
    s.imdbrating
FROM
    series s INNER JOIN seriescountry sc
    ON s.seriesid = sc.seriesid
    INNER JOIN t1
    ON t1.seriesid = s.seriesid
    INNER JOIN t2
    ON sc.country = t2.country AND s.imdbrating = t2.imdbrating
ORDER BY
    country,
    title;