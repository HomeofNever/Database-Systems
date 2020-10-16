SELECT
    t1.baker,
    t2.numtimes
FROM
	(SELECT DISTINCT baker FROM technicals) as t1
   	LEFT JOIN (SELECT COUNT(*) as numtimes, baker FROM technicals t1 WHERE t1.rank = 1 GROUP BY t1.baker) AS t2
    ON t1.baker = t2.baker
WHERE
    t2.numtimes IS NOT NULL
ORDER BY
    baker,
    numtimes;