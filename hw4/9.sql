SELECT
    sop.platform,
    COUNT(*) as numseries
FROM 
    series s ,
    seriesonplatform sop
WHERE
    s.seriesid IN (
        SELECT
            s.seriesid
        FROM
            series s, 
            seriesonplatform sop
        WHERE
            sop.seriesid = s.seriesid
            AND lower(sop.platform) LIKE '%fubotv%'
    ) AND
    sop.seriesid = s.seriesid AND
    lower(sop.platform) NOT LIKE '%fubotv%'
GROUP BY
    sop.platform
ORDER BY
    numseries DESC,
    platform;
    