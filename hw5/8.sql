SELECT
    *
FROM
    (
        SELECT
            platform1,
            platform2,
            (CAST(( SELECT COUNT(*)
                    FROM
                    (
                        SELECT
                            s1.seriesid
                        FROM
                            series s1 INNER JOIN seriesonplatform sop1
                            ON s1.seriesid = sop1.seriesid
                        WHERE
                            p1.platform1 = sop1.platform 
                        INTERSECT
                        SELECT
                            s2.seriesid
                        FROM
                            series s2 INNER JOIN seriesonplatform sop2
                            ON s2.seriesid = sop2.seriesid
                        WHERE
                            p1.platform2 = sop2.platform 
                    ) AS t1
            ) AS float) / CAST(
                (
                    SELECT
                        COUNT(*)
                    FROM
                        series s3 INNER JOIN seriesonplatform sop3
                        ON s3.seriesid = sop3.seriesid
                    WHERE
                        p1.platform2 = sop3.platform 
                ) AS float)
        )::NUMERIC(5,2) AS numcommon
            FROM
            (SELECT DISTINCT
                sop1.platform as platform1,
                sop2.platform as platform2
            FROM
                seriesonplatform sop1,
                seriesonplatform sop2
            WHERE
                sop1.platform <> sop2.platform AND
                sop1.platform <> '-1' AND
                sop2.platform <> '-1'
            ) AS p1
    ) AS t
WHERE
    numcommon > 0.6
ORDER BY
    platform1, 
    platform2, 
    numcommon