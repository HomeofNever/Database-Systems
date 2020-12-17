-- Q1
SELECT DISTINCT
    cls.crn,
    cs.coursename
FROM
    courses cs INNER JOIN classes cls
    ON cs.classcode = cls.classcode
    INNER JOIN classmeetings cm
    ON cls.crn = cm.crn
WHERE
    lower(cls.semester) LIKE '%fall%' AND
    cls.year = 2020 AND
    lower(cm.dayofweek) LIKE '%tuesday%' AND
    EXISTS (
        SELECT 
            1
        FROM 
            resourcesites rs
        WHERE 
            rs.crn = cls.crn AND
            lower(rs.sitename) IN ('submitty', 'piazza')
        GROUP BY 
            rs.crn
        HAVING
            COUNT(DISTINCT rs.sitename) > 1
    );

-- Q2

WITH
    t1 AS (    
        SELECT
            cm.crn
        FROM
            classmeetings cm
        WHERE
            lower(cm.dayofweek) LIKE '%tuesday%'
        EXCEPT
        SELECT
            oh.crn
        FROM
            officehours oh
        WHERE
            lower(oh.dayofweek) LIKE '%tuesday'
    )
SELECT
    ins.id,
    ins.name
FROM
    teaches ts INNER JOIN t1
    ON t1.crn = ts.crn
    INNER JOIN instructors ins
    ON ins.id = ts.instructorid;


-- Q3

SELECT
    cls.crn,
    css.coursename
FROM
    courses css INNER JOIN classes cls
    ON css.classcode = cls.classcode
WHERE
    (
        lower(cls.semester) LIKE '%fall%' OR
        lower(cls.semester) LIKE '%spring%'
    ) AND
    cls.year = 2020 AND
    cls.crn IN (
        SELECT 
            rs.crn
        FROM
            resourcesites rs
        GROUP BY
            rs.crn
        HAVING
            COUNT(DISTINCT rs.sitename) >= 3
        UNION
        SELECT
            ts.crn
        FROM
            teaches ts
        GROUP BY
            ts.crn
        HAVING
            COUNT(ts.instructorid) = 2
    );

-- Q4

SELECT 
    ins.id,
    ins.name,
    (
        SELECT COUNT(*)
        FROM teaches ts1
        WHERE ts1.instructorid = ins.id
    ) AS numcourses,
    (
        SELECT COUNT(*)
        FROM resourcesites rs
        WHERE 
            rs.crn IN (
                SELECT ts2.crn FROM teaches ts2 WHERE ts2.instructorid = ins.id
            ) AND
            lower(rs.resourcetype) LIKE '%discussions%'
    ) AS numsites
FROM
    instructors ins INNER JOIN teaches ts
    ON ins.id = ts.instructorid;

-- Q5

SELECT
    oh.crn,
    oh.dayofweek,
    oh.starttime
FROM
    officehours oh
WHERE
    oh.crn IN (
            SELECT 
                ex.crn
            FROM
                exams ex
            GROUP BY
                ex.crn
            HAVING
                COUNT(*) = 1
        );

-- Q6

WITH 
    t1 AS (
        SELECT 
            en.crn,
            COUNT(*) as studentnum
        FROM
            enrollment en
        WHERE
            en.crn IN (
                SELECT
                    cls.crn
                FROM
                    classes cls
                WHERE
                    lower(cls.semester) LIKE '%fall%' AND
                    cls.year = 2020 AND
                    EXISTS (
                        SELECT 
                            1
                        FROM    
                            resourcesites rs
                        WHERE
                            rs.crn = cls.crn AND
                            lower(rs.sitename) LIKE '%webex%'
                    )
            )
        GROUP BY
            en.crn
    ),
    t2 AS (
        SELECT 
            MAX(studentnum) as maxnum
        FROM 
            t1
    )
SELECT
    oh.dayofweek,
    oh.starttime,
    t1.studentnum
FROM
    officehours oh INNER JOIN t1
    ON oh.crn = t1.crn INNER JOIN t2
    ON t1.studentnum = t2.maxnum;

-- Q7

INSERT INTO
    enrollment
SELECT
    cls.crn
    std.studentid
FROM
    classes cls,
    students std
WHERE
    cls.sectionno = 1 AND
    lower(cls.semester) LIKE '%spring%' AND
    cls.year = 2021
    AND EXISTS (
        SELECT
            1
        FROM
            resourcesites rs
        WHERE
            rs.crn = cls.crn AND
            lower(rs.sitename) LIKE '%signal%'
    ) AND
    std.firstname = 'Baby' AND
    std.lastname = 'Yoda';

-- Q8

BEGIN;

UPDATE
    instructors
SET note='inappropriate resource: TikTok'
WHERE
    id IN (
        WITH
        t1 AS (
                SELECT
                    rs.crn
                FROM
                    resourcesites rs
                WHERE
                    lower(rs.sitename) LIKE '%tiktok%'
            )
        SELECT
            ts.instructorid
        FROM
            teaches ts INNER JOIN t1
            ON ts.crn = t1.crn
    );

DELETE FROM classes
WHERE
    crn IN (
          SELECT
                rs.crn
            FROM
                resourcesites rs
            WHERE
                lower(rs.sitename) LIKE '%tiktok%'
    )

COMMIT;


-- Q9

BEGIN;
CREATE TABLE a(val INT) ;
CREATE TABLE b(val INT) ;
CREATE FUNCTION atrgf () RETURNS trigger AS $$
BEGIN
IF NEW.val > 3 THEN
INSERT INTO b SELECT sum(val) FROM a;
END IF ;
RETURN NEW;
END ;
$$ LANGUAGE plpgsql;
CREATE TRIGGER atrg BEFORE INSERT ON a
FOR EACH ROW EXECUTE FUNCTION atrgf();
CREATE FUNCTION btrgf () RETURNS trigger AS $$
BEGIN
IF NEW.val - OLD.val > 5 THEN
INSERT INTO a VALUES (NEW. val) ;
END IF ;
RETURN NEW;
END ;
$$ LANGUAGE plpgsql;
CREATE TRIGGER btrg AFTER UPDATE ON b
FOR EACH ROW EXECUTE FUNCTION btrgf();

COMMIT;

BEGIN ;
INSERT INTO a VALUES(4) ;
INSERT INTO a VALUES(2) ;
INSERT INTO a VALUES(5) ;
UPDATE b SET val = 14 WHERE val = 4 ;
INSERT INTO a VALUES(8) ;
UPDATE b SET val = val*10 WHERE val < 10 ;
COMMIT ;