SELECT
	fullname,
    COALESCE(numtimes, 0) as numtimes
FROM
	bakers b
   	LEFT JOIN (SELECT COUNT(*) as numtimes, baker FROM showstoppers st WHERE lower(st.make) LIKE '%chocolate%' GROUP BY baker) AS t
    ON t.baker = b.baker
ORDER BY
    fullname,
    numtimes;
