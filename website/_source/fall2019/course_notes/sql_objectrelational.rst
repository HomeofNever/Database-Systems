
SQL - Object-Relational Extensions
===================================
      
- Postgresql and many other databases actually have many extensions
  that go well beyond the relational data model.

- As these extensions violate relational data model, think about
  what you are giving up and use them sparingly!

  - Simplicity of data model and queries
  - Optimizations may not be as easy to perform

- We will go through some of these here, using Postgresql as an
  example.
  
Semantic Hierarchies - Inheritance
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Recall in E-R diagrams, we talked about ISA 
  relationships.

  - A isa B, meaning A inherits all the 
    attributes of B (and adds some more)
    
- Postgresql allows you to define class hierarchies:

  See :download:`example database to be used <databases/inheritance.sql>`.


  ::

     CREATE TABLE cities (
          name            text
          , population      float
          , altitude        int     -- in feet
     );
     
     CREATE TABLE capitals (
          state           char(2)
     ) INHERITS (cities);

- Querying subtables:

  ::

     SELECT
        name
	, altitude
     FROM
        cities
     WHERE
        altitude > 50;
     
  Includes all cities, i.e. capitals as well.

  ::
     
     SELECT
        name
	, altitude
     FROM ONLY
        cities
     WHERE
        altitude > 50;

  Includes only cities, not capitals.


- To find out which table a row comes from:

  ::

     SELECT
         p.relname
	 , c.name
	 , c.altitude
     FROM
         cities c
	 , pg_class p
     WHERE
         c.altitude > 50
	 and c.tableoid = p.oid;
     
     Output:
     relname   |   name    | altitude
     ----------+-----------+----------
     cities    | Las Vegas |     2174
     cities    | Mariposa  |     1953
     capitals  | Madison   |      84  


- Semantic hierarchies about sets of objects and their relationship
  to each other.

  - A type of object (capital) is a special type of city.
  - All cities include the capitals.


Complex objects
~~~~~~~~~~~~~~~~~~~

- You can create user defined types 
  
  ::

     create type phone_type as (
          num varchar(12)
          , type varchar(50)
     );

     create table person (
          id int
	  , name varchar(30)
	  , phone phone_type
     ) ;

     insert into person values(
          1
	  , 'Kara Danvers'
	  , ('555-1234','work')::phone_type
     ) ;

     select * from person ;
      
      id |     name     |      phone      
     ----+--------------+-----------------
      1 | Kara Danvers | (555-1234,work)


- These complex types really go against the first normal form: that
  all values should be atomic. But, they allow multiple related values
  to be encapsulated.
  
- You can access the types using dot notation
  
  ::

     select * from person where (phone).type = 'work';
     
- Technically you should store the both attributes for phone separately,
  but this way, you can tell that they belong together.

- You can also define user defined types to be restricted domains
  of values and then use in multiple places.

Collection of Values
---------------------

- In addition to records (like the one above), you can also define
  collection of values.

- Arrays:

  ::

     CREATE TABLE tictactoe (
         squares   integer[3][3]
     );

     INSERT INTO tictactoe VALUES('{{1,2,3},{4,5,6},{7,8,9}}');

     SELECT squares[3][2] FROM tictactoe; --not zero indexed
     
     squares 
     ---------
     8
     (1 row)


     CREATE TABLE messages (
          msg  text[]
     ) ;

     INSERT INTO messages VALUES ('{"hello", "world"}') ;
     INSERT INTO messages VALUES ('{"I", "feel", "so", "free"}') ;

     SELECT msg[2] FROM messages ;
     msg  
     -------
     world
     feel
     (2 rows)

     SELECT msg[2:3] FROM messages; --slicing, really?

     msg    
     -----------
     {world}
     {feel,so}
     (2 rows)

- The best of use complex types is to write procedures/functions
  using pl/pgsql or a programming language like C.

Typed objects and methods
---------------------------

- The main use of typed objects is to create extensions for handling
  specific types of data.

- For each data type, there are specific methods that apply to them,
  like an object-oriented programming language!

- Some really useful examples:

  - Geographic data: points (geo locations), polygons (state, city
    boundaries), line segments (roads, rivers) 

  - Text data: vectors of words and weights for each word

  - JSON

    ::
       
       SELECT '{"foo": {"bar": "baz"}}'::jsonb;
    
       jsonb          
       -------------------------
       {"foo": {"bar": "baz"}}
  
       SELECT '{"foo": {"bar": "baz"}}'::jsonb->'foo';
       
       ?column?    
       ----------------
       {"bar": "baz"}


Geographic Data
-----------------

- PostGIS is an extension for supporting geographic data
  with many useful data types of functions.

- First install postgis and create the extension from a superuser:

  ::

     create extension postgis;
     create database geodb owner sibeladali template template_postgis ;

- Now you can use all the data types and methods available in postgis.
  
  ::

     CREATE TABLE bwithloc (
          name  VARCHAR(100)
	  , location geography(POINT,4326)
     ) ;	  

     insert into bwithloc values('Rensselaer Polytechnic Institute',
          ST_GeographyFromText('SRID=4326;POINT(42.7308634 -73.6816793)'));

     insert into bwithloc values('Shalimar Restaurant',
          ST_GeographyFromText('SRID=4326;POINT(42.732293 -73.688473)'));
	  
     insert into bwithloc values('The Placid Baker',
          ST_GeographyFromText('SRID=4326;POINT(42.7313916 -73.690868)'));

- SRID shows the projection used to compute the latitude and longitude.
  
- You can also enter polygons as arrays of points, line segments are arrays
  of lines, etc.

- Many geography functions are available (distance is in meters):

  ::

     SELECT
        b1.name
	, b2.name
	, ST_DISTANCE(b1.location, b2.location)
     FROM
        bwithloc b1
	, bwithloc b2
     WHERE
        b1.name < b2.name ;

- Other examples:	

  - Check whether a point is inside a polygon (which city is this
    restaurant in)?

  - Check the length of a line segment
  
Text Querying
--------------

- The text queries we have seen so far very simplistic: find if
  the text contains a specific word.

- More sophisticated approaches treat text as a collection of
  words or tokens.
  
  - If you want to learn more, information retrieval is a field
    that studies this!

- Postgresql supports text processing:

  ::

     SELECT to_tsvector('fat cats ate fat rats');

     to_tsvector            
     -----------------------------------
     'ate':3 'cat':2 'fat':1,4 'rat':5

  numbers show the location of the keyword in the text.     

- Text queries will consist of boolean connection of keywords,
  tokenized and stop words removed:

  ::

     SELECT to_tsquery('english', 'The & Fat & Rats');
     to_tsquery   
     ---------------
     'fat' & 'rat'


- You can search a keyword query in a document by relevance. The
  number of times a word appears will increase the relevance of the
  text to the query.

  We will use the Yelp database as an example:

  ::

     SELECT
        b.name
	, ts_rank_cd(to_tsvector('english', r.review_text), query) AS rank
     FROM
        reviews r
	, businesses b
	, to_tsquery('pizza & (crust | sauce) & (delicious|tasty)') query
     WHERE
        b.business_id = r.business_id
	and to_tsvector('english', r.review_text) @@ query 
     ORDER BY
        rank DESC
     LIMIT 10;	

                 name            |   rank    
     ----------------------------+-----------
      DeFazio's Pizzeria         |      0.05
      Little Bites and More      |      0.05
      Notty Pine Tavern          | 0.0366667
      Red Front Restrnt & Tavern | 0.0285714
      New York Style Pizza       |     0.025
      Milano Restaurant          | 0.0218698
      DeFazio's Pizzeria         | 0.0202986
      The Fresh Market           |      0.02
      Dante's Pizzeria           | 0.0192982
      Labella Pizza              | 0.0155556


Summary
---------

- Postgresql extensible with many new data types and
  associated methods.

- We will also see how it is possible to create the appropriate
  indices for these data types.


