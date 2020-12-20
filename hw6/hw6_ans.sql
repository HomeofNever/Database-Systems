CREATE OR REPLACE FUNCTION ratingjoin(iir float, irr float) RETURNS float AS $$
DECLARE
   val float ;
BEGIN
   val = 0 ;
   IF iir IS NOT NULL AND irr IS NOT NULL THEN
       val = (iir+ irr/10)/2 ;
   ELSIF iir IS NULL AND irr IS NOT NULL THEN
       val = irr/10 ;
   ELSIF iir IS NOT NULL AND irr IS NULL THEN
       val = iir ;
   END IF;       
   RETURN val::float ;
END ;
$$ LANGUAGE plpgsql ;



CREATE OR REPLACE FUNCTION
    recommendation(inputseries integer array
               , topk int
	       , w1 float, w2 float, w3 float, w4 float)
    RETURNS varchar AS $$
DECLARE
   values VARCHAR ;
   myrow RECORD ;
BEGIN
   CREATE TABLE inputs AS SELECT *
         FROM unnest(inputseries) as input(seriesid) ;

   CREATE TABLE scores (seriesid INT, score float, stype varchar(10));
   
   -- compute a1
   INSERT INTO scores
   SELECT
      sc2.seriesid
      , count(*)::float * w1
      , 'a1'
   FROM
      seriescategory sc1
      , seriescategory sc2
      , inputs i
   WHERE
      sc1.seriesid = i.seriesid
      and sc1.category = sc2.category
      and sc2.seriesid not in (select seriesid from inputs)
   GROUP BY
      sc2.seriesid;

   -- compute a2
   INSERT INTO scores
   SELECT
       seriesid
       , count(*)::float * w2
       , 'a2'
   FROM
      seriesonplatform sp
   WHERE
      sp.seriesid not in (select seriesid from inputs)
   GROUP BY
      sp.seriesid;

   -- compute a3
   INSERT INTO scores
   SELECT
      sc2.seriesid
      , count(*)::float * w3
      , 'a3c'
   FROM
      seriescast sc1
      , inputs i
      , seriescast sc2
   WHERE
      sc1.seriesid = i.seriesid
      and sc1.castname = sc2.castname
      and sc2.seriesid not in (select seriesid from inputs)
   GROUP BY
      sc2.seriesid ;

   INSERT INTO scores
   SELECT
      sd2.seriesid
      , count(*)::float * w3
      , 'a3d'
   FROM
      seriesdirectors sd1
      , inputs i
      , seriesdirectors sd2
   WHERE
      sd1.seriesid = i.seriesid
      and sd1.director = sd2.director
      and sd2.seriesid not in (select seriesid from inputs)
   GROUP BY
      sd2.seriesid ;

   INSERT INTO scores
   SELECT
      seriesid
      , ratingjoin(imdbrating, rottentomatoes) * w4
      , 'a4'
   FROM
      series
   WHERE
      seriesid not in (select seriesid from inputs)
      and ( imdbrating is not null or rottentomatoes is not null );

   values = '';
   FOR myrow IN
     SELECT
        s.title 
        , sum(sc.score) as totalscore
     FROM
        scores sc
        , series s
     WHERE
        sc.seriesid = s.seriesid
     GROUP BY
        s.seriesid
     ORDER BY
        totalscore desc
        , title asc
     LIMIT
        topk
   LOOP
      values = values || myrow.title || ' (' || myrow.totalscore::numeric(6,3) || ')' || E'\n' ;
   END LOOP ;
   
   DROP TABLE inputs ;
   DROP TABLE scores ;
   RETURN values ;
END ;
$$ LANGUAGE plpgsql ;

