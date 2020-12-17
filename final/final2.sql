WITH
    t1 AS (
        SELECT 
            crn
        FROM 
            classmeetings
        WHERE 
            dayofweek = 'wednesday'
    ),
    t2 AS (
        SELECT
            crn
        FROM
            classes
        EXCEPT
        SELECT
            crn
        FROM
            officehours
    )
SELECT
    crn,
    COUNT(DISTINCT studentid)
FROM
    enrollment el 
    INNER JOIN t1
    ON t1.crn = el.crn
    INNER JOIN t2
    ON t2.crn = el.crn
GROUP BY
    crn;