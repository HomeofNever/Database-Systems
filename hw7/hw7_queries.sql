-- q1
select title from series where yearreleased = 2020;

-- q2
select title from series where yearreleased <= 1950 and yearreleased >= 1941;

-- q3
select title from series where rottentomatoes <= 100 and rottentomatoes >= 95;

-- q4
select title from series where rottentomatoes <= 60 and rottentomatoes >= 55;

-- q5
select title from series where imdbrating <= 6 and imdbrating >= 5.5;

-- q6
select title from series where imdbrating <= 100 and imdbrating >= 9.5;

--q7
select title from series where contentrating = 'all' and imdbrating >= 9;

--q8
select title from series where
          rottentomatoes <= 60 and rottentomatoes >= 55
	  and imdbrating<= 6 and imdbrating>= 5.5
	  and contentrating = 'all';

--q9          
select seriesid from seriescast where castname = 'David Attenborough';

--q10
select seriesid from seriescast where castname = 'Jodie Whittaker';

--q11
select seriesid from seriescountry where country = 'Japan';

--q12
select seriesid from seriescountry where country = 'Greece';
