
Example Database
=================

We will use this example database in various examples. The data is not
complete or not necessarily accurate. We will discuss this in detail
in class.

MarvelHeroes
------------
===  ===============  ===================
hid   hero            realname           
===  ===============  ===================
h1   Captain America  Steve Rogers       
h2   Iron Man         Tony Stark         
h3   Hulk             Bruce Banner       
h4   Thor             Thor               
h5   Hawkeye          Clint Barton       
h6   Black Widow      Natasha Romanoff   
h7   Ant-Man          Scott Lang         
h15  Jessica Jones    Jessica Jones
===  ===============  ===================

DCHeroes
--------
===  ===============  ===================
hid   hero            realname           
===  ===============  ===================
h8   Superman         Clark Kent         
h9   Batman           Bruce Wayne        
h10  Supergirl        Kara Danvers       
h11  Flash            Barry Allen        
h12  Arrow            Oliver Queen       
h13  Green Lantern    Hal Jordan         
h14  Wonder Woman     Diana Prince       
===  ===============  ===================

TVHeroes
----------
===  ===============  ===================
hid   hero            realname           
===  ===============  ===================
h3   Hulk             Bruce Banner       
h8   Superman         Clark Kent         
h9   Batman           Bruce Wayne        
h10  Supergirl        Kara Danvers       
h11  Flash            Barry Allen        
h12  Arrow            Oliver Queen       
h14  Wonder Woman     Diana Prince       
h15  Jessica Jones    Jessica Jones
===  ===============  ===================


Movies
-------

===  ===================================  ====
mid  moviename                            year
===  ===================================  ====
m1   Captain America: The First Avenger   2011
m2   Iron Man                             2008
m3   Iron Man 2                           2010
m4   The Incredible Hulk                  2008
m5   Thor                                 2011
m6   The Avengers                         2012
m7   Iron Man 3                           2013
m8   Thor: The Dark World                 2013
m9   Captain America: The Winter Soldier  2014
m10  Guardians of the Galaxy              2014
m11  Avengers: Age of Ultron              2015
m12  Ant-Man                              2015
m13  Superman Returns                     2006
m14  The Dark Knight                      2008
m15  Green Lantern                        2011
m16  Wonder Woman                         2017
===  ===================================  ====


TVShows
--------

===  ==============  =====  =======  =========  ========  =====
sid  showname        hid    Channel  FirstYear  LastYear  Ended
===  ==============  =====  =======  =========  ========  =====
s1   Arrow           h12    CW       2012       2016      No
s2   The Flash       h11    CW       2012       2016      No
s3   Supergirl       h10    CBS      2015       2016      No
s4   Gotham          h9     FOX      2014       2016      No
s5   Jessica Jones   h15    Netflix  2015       2016      No
s6   The Flash       h11    CBS      1990       1991      Yes
===  ==============  =====  =======  =========  ========  =====

HeroInMovie
------------
===   ====
hid   mid
===   ====
h1    m1
h2    m2
h2    m3
h3    m4
h4    m5
h1    m6
h2    m6
h3    m6
h4    m6
h5    m6
h6    m6
h2    m7
h4    m8
h1    m9
h1    m11
h2    m11
h3    m11
h4    m11
h5    m11
h6    m11
h7    m12
h8    m13
h9    m14
h13   m15
h14   m16
===   ====
