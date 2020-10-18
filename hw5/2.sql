SELECT
    country,
    COUNT(*) as numseries
FROM
    series s 
    INNER JOIN seriescountry sc
    ON s.seriesid = sc.seriesid
    INNER JOIN seriescategory sca
    ON s.seriesid = sca.seriesid
WHERE
    lower(category) LIKE '%tv comedies%'
GROUP BY
    country
ORDER BY
    numseries DESC,
    country;