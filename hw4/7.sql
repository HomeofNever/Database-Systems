SELECT
    s.title,
    COUNT(sc) as numcountries,
    COUNT(sop) as numplatforms
FROM
    seriescountry sc,
    series s,
    seriesonplatform sop
WHERE
    s.seriesid = sc.seriesid AND
    s.seriesid = sop.seriesid
GROUP BY 
    s.title
HAVING
    COUNT(DISTINCT sc.country) > 2
ORDER BY 
    numcountries DESC,
    title;
