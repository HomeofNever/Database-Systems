WITH
	t1 AS (SELECT
                crn
            FROM
                exams
            WHERE
                starttime >= '2020/12/11' AND
                starttime <= '2020/12/25'
            GROUP BY
                crn
            HAVING
                count(*) >= 2 OR SUM(pointvalue) = 30
            INTERSECT
            SELECT
                crn
            FROM
                enrollment
            WHERE
                studentid = (SELECT
                                    studentid 
                                FROM
                                    students
                                WHERE
                                    email = "grogu@disney.edu" and
                                    firstname = "Baby" and 
                                    lastname = "Yoda")
    )
SELECT
    cls.crn, crs.coursename
FROM
    classes cls 
    INNER JOIN courses crs 
    ON cls.classcode = crs.classcode
    INNER JOIN t1
    ON t1.crn = cls.crn