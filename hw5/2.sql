SELECT
 t1.country, COALESCE(numseries, 0 ) as numseries
FROM
    ( SELECT DISTINCT country FROM seriescountry sc ) AS t1
    LEFT JOIN  (
                            SELECT 
                               country,
                               COUNT(*) as numseries
                            FROM series s 
                            INNER JOIN seriescountry sc
                            ON s.seriesid = sc.seriesid
                            INNER JOIN seriescategory sca
                            ON s.seriesid = sca.seriesid
                        WHERE
                            lower(category) LIKE '%tv comedies%'
                        GROUP BY
                            country) AS t2
    on t1.country = t2.country
ORDER BY
    numseries DESC,
    country;