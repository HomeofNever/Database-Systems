WITH 
    t1 AS (
        SELECT 
            crn
        FROM 
            classes
        WHERE
            semester = "Fall" AND
            year = 2020
    ),
    t2 AS (
        SELECT
            crn
        FROM 
            classes
        WHERE
            year < 2020
    ),
    t3 AS (
        SELECT
            crn
        FROM
            teaches
        WHERE
            instructorid = (SELECT
                                id
                            FROM
                                instructors
                            WHERE
                                name = "Ahsoka Tano")
    )
SELECT
    rs.sitename
FROM
    resourcesites rs 
    INNER JOIN t1 ON rs.crn = t1.crn
    INNER JOIN t3 ON rs.crn = t3.crn
WHERE
    rss.crn NOT IN (t2);