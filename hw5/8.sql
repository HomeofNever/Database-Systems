WITH
    t1 AS (
        SELECT
            sop1.platform as platform1,
            sop2.platform as platform2, 
            count(*) as common 
        FROM
            seriesonplatform sop1 ,
            seriesonplatform sop2 
        WHERE 
            sop1.platform <> sop2.platform AND
            sop1.seriesid = sop2.seriesid
        GROUP BY
            sop1.platform, sop2.platform
    ),
    t2 AS (
            SELECT
                platform,
                COUNT(*) as numseries
            FROM
                seriesonplatform
            WHERE
                platform  <> '-1'
            GROUP BY
                platform
    ) 
SELECT
    platform1,
    platform2,
    (CAST (common  AS FLOAT) / (CAST (numseries AS FLOAT)))::NUMERIC(5, 2) as numcommon
FROM
    t1 INNER JOIN t2
    ON t1.platform1 = t2.platform
WHERE
     common > numseries * 0.6
ORDER BY
    platform1, 
    platform2, 
    numcommon;