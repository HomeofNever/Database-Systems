
SELECT 'Query 1';

SELECT
    director
FROM
    moviesdirectors
WHERE
    director <> 'Steven Spielberg'
GROUP BY
    director
HAVING
    count(*) = (SELECT count(*)
                FROM moviesdirectors
		WHERE director = 'Steven Spielberg')
ORDER BY
    director
;

SELECT 'Query 2';

SELECT
   sc.country
   , count(scat.seriesid) as numseries
FROM
   seriescountry sc
   left join seriescategory scat
       on sc.seriesid = scat.seriesid
          and scat.category = 'TV Comedies'
GROUP BY
   sc.country
ORDER BY   
   numseries desc
   , sc.country asc;

SELECT 'Query 3';

with ordered1 as (
select
   language
   , count(*) as num
from
   movieslanguages
group by
   language
order by
   num desc
   , language asc
limit 40),
ordered2 as (
select
   *
from
   ordered1
order by
   num desc
   , language asc
limit 14)
select language, num from ordered1
except
select language, num from ordered2
order by num asc, language asc
;

SELECT 'Query 4';

WITH numl AS (
  SELECT
     movieid
     , count(*) as numlanguages
  FROM
     movieslanguages
  GROUP BY
     movieid
)
SELECT
   m.title
   , numl.numlanguages
FROM
   movies m
   , numl
WHERE
   m.movieid = numl.movieid
   and numl.numlanguages =
           (SELECT max(numlanguages) FROM numl)
ORDER BY
   title ASC
;

SELECT 'Query 5';

WITH valbefore AS (
SELECT
   avg(m.imdbrating)::numeric(5,2) as avgbefore
FROM
   movies m
   , moviesgenres mg
WHERE
   m.movieid = mg.movieid
   and lower(mg.genre) = 'horror'
   and m.year < 2000 ) , 
valafter AS (
SELECT
   avg(m.imdbrating)::numeric(5,2) as avgafter
FROM
   movies m
   , moviesgenres mg
WHERE
   m.movieid = mg.movieid
   and lower(mg.genre) = 'horror' --
   and m.year > 2000 )
SELECT
   valbefore.avgbefore
   , valafter.avgafter
   , valbefore.avgbefore - valafter.avgafter as avgdiff

FROM
   valbefore
   , valafter ;

SELECT 'Query 6';

SELECT
   sc.country
   , s.title
   , s.imdbrating
FROM
   seriescountry sc
   , series s
WHERE
   s.seriesid = sc.seriesid
   and s.imdbrating >= 7.5
   and sc.country in ('Turkey','France','China','India','Thailand','Japan')
   and not exists (SELECT 1
                   FROM seriescountry sc2
		   WHERE sc2.seriesid = s.seriesid
		         AND sc2.country <> sc.country)
ORDER BY
   sc.country
   , s.imdbrating
   , s.title;

SELECT 'Query 7';

WITH seriesonlycountry AS (
SELECT
   sc.country
   , s.title
   , s.imdbrating
FROM
   seriescountry sc
   , series s
WHERE
   s.seriesid = sc.seriesid
   and sc.country <> 'United States'
   and not exists (SELECT 1
                   FROM seriescountry sc2
		   WHERE sc2.seriesid = s.seriesid
		         AND sc2.country <> sc.country)
)
SELECT *
FROM seriesonlycountry soc
WHERE soc.imdbrating =
            (SELECT max(imdbrating)
             FROM seriesonlycountry soc2
             WHERE soc.country = soc2.country)
ORDER BY
   soc.country
   , soc.title
;

SELECT 'Query 8';

with platformcommon as (
select
    sp1.platform as platform1
    , sp2.platform as platform2
    , count(*)::float as numcommon
from
    seriesonplatform sp1
    , seriesonplatform sp2
where    
    sp1.seriesid = sp2.seriesid
    and sp1.platform <> sp2.platform
group by
    sp1.platform
    , sp2.platform
)
select
   p.platform1
   , p.platform2
   , (p.numcommon::float/count(*)::float)::numeric(5,2) as numcommon
from
   seriesonplatform sp
   , platformcommon p
where
   sp.platform = p.platform1
group by
   p.platform1
   , p.platform2
   , p.numcommon
having
   (p.numcommon::float/count(*)::float)::numeric(5,2) > 0.6
order by
   platform1
   , platform2
   , numcommon ;

--  Return the name of cast members who have starred in
--  more than two of the same director's movies and did not direct any
--  movies themselves. Order results by cast member name ascending.

SELECT 'Query 9';

select distinct
   mc.castname
from
   moviescast mc
   , moviesdirectors md
where
   mc.movieid = md.movieid
group by
   mc.castname
   , md.director
having
   count(distinct mc.movieid)>2
except
select
   director
from
   moviesdirectors
order by
   castname asc
;
