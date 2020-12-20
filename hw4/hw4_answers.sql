

SELECT 'Query 1';

-- Return the title and directors of series with at least 15 seasons
-- despite having an IMDB rating of less than 5. Order results by
-- title and director ascending.

SELECT
   s.title
   , sd.director
FROM
   series s
   , seriesdirectors sd
WHERE
   s.seriesid = sd.seriesid
   and s.imdbrating <= 5
   and s.seasons >= 15
ORDER BY
   title
   , director
;


SELECT 'Query 2';

-- Find the number of movies (nummovies) that have no imdb or rotten
-- tomatoes rating, and either has no year value or year is after
-- 2015.

SELECT
   count(*) as nummovies
FROM
   movies m
WHERE
   m.imdbrating is null
   and m.rottentomatoes is null
   and (m.year is null or m.year>2015);


SELECT 'Query 3';

-- Return the title, director of all movies IMDB rating of 8 or higher
-- and is available in English and in at least one other language, and
-- are in at least one of the following genres: Action, Sci-Fi,
-- Adventure or Drama. Order results by title and director ascending.

SELECT DISTINCT
    m.title
    , md.director
FROM
    movies m
    , moviesdirectors md
    , moviesgenres mg
    , movieslanguages ml
    , movieslanguages ml2
WHERE
    m.movieid = md.movieid
    and m.movieid = mg.movieid
    and m.movieid = ml.movieid
    and m.movieid = ml2.movieid
    and m.imdbrating >= 8
    and mg.genre in ('Action', 'Sci-Fi', 'Adventure', 'Drama')
    and ml.language = 'English'
    and ml2.language <> 'English'
ORDER BY
    title
    , director ;

SELECT 'Query 4';

-- Return the id, title of all movies and TVshows that are only
-- available in Italy. Return an additional column called
-- streamingtype that has the value ’movie’ or ’series’ depending on
-- the source. Order results by the title and streamingtype in
-- descending order.

(SELECT
   m.movieid as id
   , m.title
   , 'movie' as streamingtype
FROM
   movies m
   , moviescountry mc
WHERE
   m.movieid = mc.movieid
   and mc.country = 'Italy'
EXCEPT   
SELECT
   m.movieid as id
   , m.title
   , 'movie' as streamingtype
FROM
   movies m
   , moviescountry mc
WHERE
   m.movieid = mc.movieid
   and mc.country <> 'Italy'
) UNION (
SELECT
   s.seriesid as id
   , s.title
   , 'series' as streamingtype
FROM
   series s
   , seriescountry sc
WHERE
   s.seriesid = sc.seriesid
   and sc.country = 'Italy'
EXCEPT   
SELECT
   s.seriesid as id
   , s.title
   , 'series' as streamingtype
FROM
   series s
   , seriescountry sc
WHERE
   s.seriesid = sc.seriesid
   and sc.country <> 'Italy')
ORDER BY
   title desc
   , streamingtype desc ;


SELECT 'Query 5';

-- Return the total number of tuples in the movies relation
-- (numtuples), total number of tuples with a date added value
-- (numdate), earliest year and last year for a movie (minyear,
-- maxyear), average duration for a movie and average imdb rating
-- (avgrating).

SELECT
   count(*) as numtuples
   , count(date_added) as numdate
   , min(year) as minyear
   , max(year) as maxyear
   , avg(left(duration, strpos(duration,' '))::int)::numeric(5,2) as avgduration
   , avg(imdbrating)::numeric(5,2) as avgrating
FROM
   movies ;

SELECT 'Query 6';

-- Find cast members who have both been in a movie and a TV Series in
-- the same genre for either Mystery or Thriller genres. Return the
-- name of the cast members and the total number of movies (nummovies)
-- and series (numseries) they have been in one of these genres. Order
-- by the nummovies, numseries and castname ascending.

SELECT
    mc.castname
    , count(distinct mc.movieid) as nummovies
    , count(distinct sc.seriesid) as numseries
FROM
    moviescast mc
    , seriescast sc
    , moviesgenres mg
    , seriesgenres sg
WHERE
    mc.castname = sc.castname
    and mg.movieid = mc.movieid
    and sg.seriesid = sc.seriesid
    and sg.genre = mg.genre
    and sg.genre in ('Mystery', 'Thriller')
GROUP BY
    mc.castname
ORDER BY
    nummovies
    , numseries
    , castname;

SELECT 'Query 7';

-- Find series that are available in at least 3 countries. Return the
-- title of these series, the total number countries (numcountries)
-- and streaming platforms they are available in. Order results by
-- numcountries descending and title ascending.


SELECT
   s.title
   , count(distinct sc.country) numcountries
   , count(distinct sp.platform) numplatforms
FROM
   series s
   , seriescountry sc
   , seriesonplatform sp
WHERE
   s.seriesid = sc.seriesid
   and s.seriesid = sp.seriesid
GROUP BY
   s.seriesid
HAVING
   count(distinct sc.country)>= 3
ORDER BY
   numcountries desc
   , title asc
;


SELECT 'Query 8';

-- For each language, find how many movies are in that
-- language. Return the language, min and max imdb and rotten tomatoes
-- ratings of movies for each language that has at least 10 movies.

-- Rename the aggregates: minimdb, maximdb, minrotten, maxrotten
-- respectively. Order results by minimdb and minrotten asc.


SELECT
   ml.language
   , min(m.imdbrating) as minimdb
   , max(m.imdbrating) as maximdb
   , min(m.rottentomatoes) as minrotten
   , max(m.rottentomatoes) as maxrotten
FROM
   movieslanguages ml
   , movies m
WHERE
   ml.movieid = m.movieid
GROUP BY
   ml.language
HAVING
   count(*) >= 10
ORDER BY
   minimdb
   , minrotten
;

SELECT 'Query 9';


-- For series that are on fuboTV, find the other platforms that they
-- are also on. For each other platform, return the platform name and
-- total number of series from fuboTV that they feature
-- (numseries). Order results by numseries desc and platform name.

SELECT
   sp2.platform
   , count(*) as numseries
FROM
   seriesonplatform sp
   , seriesonplatform sp2
WHERE
   sp.platform = 'fuboTV'
   and sp.platform <> sp2.platform
   and sp.seriesid = sp2.seriesid
GROUP BY
   sp2.platform
ORDER BY
   numseries desc
   , platform asc;


SELECT 'Query 10';

-- Return the name of all cast members who were cast in a movie added
-- after 1/1/2019 and have also directed a movie but were not cast in
-- any series. Order the results by castname ascending.




SELECT
   mc.castname
FROM
   moviescast mc
   , moviesdirectors md
   , movies m
WHERE
   mc.castname = md.director
   and mc.movieid = m.movieid
   and m.date_added > date '1/1/2019'
EXCEPT
SELECT
   castname   
FROM
   seriescast
ORDER BY
   castname asc ;

