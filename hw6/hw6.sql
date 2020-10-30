CREATE OR REPLACE FUNCTION 
    recommendation(inputseries integer array, topk int, w1 float, w2 float, w3 float, w4 float)
    RETURNS varchar AS $$
DECLARE 
    myrow RECORD;
    values VARCHAR;
BEGIN
    -- Set up temp table
    CREATE TABLE IF NOT EXISTS __my_category AS (
        SELECT 
            category,
            COUNT(*) as num
        FROM  seriescategory sc
            INNER JOIN unnest(inputseries) as input(seriesid)
            ON sc.seriesid = input.seriesid
        GROUP BY
            category
    );
    CREATE TABLE IF NOT EXISTS __my_director AS (
        SELECT 
            director,
            COUNT(*) as num
        FROM seriesdirectors sd
            INNER JOIN unnest(inputseries) as input(seriesid)
            ON sd.seriesid = input.seriesid
        GROUP BY 
            director
    );
    CREATE TABLE IF NOT EXISTS __my_castname AS(
        SELECT 
            castname,
            COUNT(*) as num
        FROM seriescast sca
            INNER JOIN unnest(inputseries) as input(seriesid)
            ON sca.seriesid = input.seriesid
        GROUP BY 
            castname
    );
    CREATE TABLE IF NOT EXISTS __my_ranking AS (
        SELECT
            seriesid,
            title,
            0 AS a1,
            0 AS a2,
            0 AS a3,
            0.0 AS a4
        FROM 
            series
        WHERE
            seriesid NOT IN (SELECT * FROM unnest(inputseries))
    );
    
    -- Calculate All a1
    FOR myrow IN 
        SELECT 
            mr.seriesid,
            category
        FROM __my_ranking mr
            INNER JOIN seriescategory sc
            ON sc.seriesid = mr.seriesid
    LOOP
        UPDATE __my_ranking 
            SET a1 = a1 +  coalesce((SELECT num FROM __my_category WHERE category = myrow.category), 0)
        WHERE seriesid = myrow.seriesid;
    END LOOP;

    -- Calculate a2
    FOR myrow IN 
        SELECT 
            mr.seriesid,
            COUNT(*) AS num
        FROM __my_ranking mr
        INNER JOIN seriesonplatform sop
        ON sop.seriesid = mr.seriesid
        GROUP BY
            mr.seriesid
    LOOP
        UPDATE __my_ranking 
        SET a2 = myrow.num
        WHERE seriesid = myrow.seriesid;
    END LOOP;

    -- Calculate a3
    FOR myrow IN 
        SELECT 
            mr.seriesid,
            director
        FROM __my_ranking mr
        INNER JOIN seriesdirectors sd
        ON sd.seriesid = mr.seriesid
    LOOP
        UPDATE __my_ranking 
        SET a3 = a3 + coalesce((SELECT num FROM __my_director WHERE director = myrow.director), 0)
        WHERE seriesid = myrow.seriesid;
    END LOOP;

    FOR myrow IN 
        SELECT 
            mr.seriesid,
            castname
        FROM __my_ranking mr
        INNER JOIN seriescast sc
        ON sc.seriesid = mr.seriesid
    LOOP
        UPDATE __my_ranking 
            SET a3 = a3 + coalesce((SELECT num FROM __my_castname WHERE castname = myrow.castname), 0)
        WHERE seriesid = myrow.seriesid;
    END LOOP;

    -- Calculate a4
    FOR myrow IN 
        SELECT 
            mr.seriesid,
            s.imdbrating,
            s.rottentomatoes
        FROM __my_ranking mr
            INNER JOIN series s
            ON s.seriesid = mr.seriesid
        WHERE
            s.imdbrating is NOT NULL AND s.rottentomatoes is NOT NULL
    LOOP
        UPDATE __my_ranking 
            SET a4 = CASE
                    WHEN myrow.imdbrating is NULL THEN (myrow.rottentomatoes + 0.0) / 10
                    WHEN myrow.rottentomatoes is NULL THEN myrow.imdbrating
                    ELSE (((myrow.rottentomatoes  + 0.0) / 10) + myrow.imdbrating) / 2
            END
        WHERE seriesid = myrow.seriesid;
    END LOOP;

    -- Calculate Score and Generate Result
    values = '';
    FOR myrow IN
        SELECT 
            seriesid,
            title,
            (w1*a1+w2*a2+w3*a3+w4*a4)::NUMERIC(6,3) as score
        FROM
            __my_ranking
        ORDER BY
            score DESC,
            title
        LIMIT
            topk
    LOOP
        values = values || myrow.title || E' (' || myrow.score || E')\n';
    END LOOP;

    -- Clear Temp Table
    DROP TABLE __my_castname;
    DROP TABLE __my_director;
    DROP TABLE __my_category;
    DROP TABLE __my_ranking;

    RETURN values;
END;
$$ LANGUAGE plpgsql ;

-- test cases
-- select recommendation (ARRAY[4987,1823,16],20,0.5,1,2,0.5);
-- select recommendation (ARRAY[4987,1823,16],20,1,1,0.5,0.5);
-- select recommendation(ARRAY[1587,13,255],20,1,0.2,2,0.3);
-- select recommendation(ARRAY[111,321,7726,369],20,1,0.2,2,0.3) ;
-- select recommendation(ARRAY[111,321,7726,369],20,10,2,0.5,0.1) ;
-- select recommendation(ARRAY[35,870,1395,82],20,1,1,1,0.5) ;
-- select recommendation(ARRAY[35,870,1395,82],20,0.2,10,10,1) ;