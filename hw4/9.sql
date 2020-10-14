For series that are on fuboTV, find the other platforms that they are also on. For each other platform, return the total number of series from fuboTV that they feature (numseries). Order results by numseries.

SELECT
FROM
    series s, 
    seriesonplatform sop
WHERE
    sop.seriesid = s.seriesid
    AND lower(sop.platform) LIKE '%fubotv%'
    