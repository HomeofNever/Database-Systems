
Database Tuning
=================

- Tuning is the act of changing an application and DBMS environment to
  improve system performance

  
- Performance is usually measured in terms of response time

  - Time to get the first tuple
  - Time to get all the tuples to a query
    
- A workload consists of various operations performed by the system
  and their frequency

  - It is important to tune to improve workload, not just a single query
    
  - Some queries are bottlenecks: performed frequently and/or are very
    expensive
    
- Remember: when you improve the performance of one operation, other
  operations may slow down

  For example, creating an index to speed up a query will slow down
  insert/update operations
  
Database Tuning Steps
-------------------------

- Step 1: buy more or faster hardware
  
  memory is crucial for buffering query operations and caches for
  various operations
  
  hard disk speed is crucial, buy faster and more disks to improve the
  parallelism

- Step 2: tune the system installation
  
  databases provide a large number of tunable parameters, read database
  administration books

  learn about making better use of multiple CPUs


Disk caches
~~~~~~~~~~~~

- A cache is a set of buffer pages maintained by the DBMS for a
  specific purpose
  
- Data cache for reading pages containing the index or the relation
  
- Procedure cache for storing previously constructed query plans

- Caches are usually shared between concurrent users

- Any requested item must be brought to cache from disk to read/modified
  
- If it is already in the cache, then the cache has a hit, otherwise
  the cache has a miss
  
- Since each hit is a savings in time, hit ratio must be maximized
  (some application designers seek 90% hit ratio)

Cache replacement algorithms
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- If a new item has to be inserted into the cache, another item might
  need to be removed.
  
- Cache replacement algorithm decides what should be removed, LRU
  (least recently used), MRU (most recently used)
  
  - A recently used page may be used for an update in near future (LRU)

  - A page read in table scan is no longer needed (MRU)
  
  - Sophisticated caches may take the algorithm using the database into
    account
  
  - How would  you use the cache for an index page?
    
- A dirty page is a page modified by an uncommitted transaction -if
  this page is moved out of cache, it must be written back to disk

Tuning the cache
~~~~~~~~~~~~~~~~~~~~~

- Divide the cache and bind a specific item to a cache (different
  tables may be cached in different caches)
  
- Divide the cache into pools of varied size, 2K, 4K, 8K, etc.
  
  - The query processor can choose the best available cache for a query
    (retrieve large sequences for table scans, even prefetch disk pages
    that are expected to be requested next)
  
- Procedure cache may use previously optimized query plans

  Hint: use program variables to increase possible reuse 

  ::

     SELECT P.name FROM Professor P WHERE P.deptId = :deptid

  When you use prepared statements such as this, query and parameters
  are sent separately, allowing the same query for different
  parameters to use the same query plan.
  
Partitioning
---------------

- Step 3: partition your data

- Vertical partitioning divides the attributes in the relation and
  distributes them to different disks or tablespaces

  Frequently queried attributes could be separated from infrequently
  queried attributes.
    
- Horizontal partitioning divides the tuples in the relation to
  multiple disks

  Allows parallelism in reading data from disk

  Some optimizers are able to concentrate on a single partition given
  a specific query

  
Denormalization
----------------

- Step 4: change your data model
  
- Normalization reduces redundancy and null values
  
  - Lower storage requirements, simple queries and updates will be
    faster
  
  - Results in more tables, hence complex queries need more joins
    

    ::

       SELECT
           FAN.Title
       FROM
           Films F
	   , FilmAlternateNames FAN
       WHERE
           F.filmid = FAN.filmid;
       
- Denormalization stores relations in a non-optimal manner

Examples of denormalization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Store alternate names in a string and use application code to update
  and print the alternate names
  
- Add extra columns for frequently accessed information
    
  Example: number of movies per actor:

  ::

     SELECT
        a.name
	, a.surname
	, count(distinct mr.movieid)
     FROM
        actors a
	, movieroles mr
     WHERE
        a.id=mr.actorid
     GROUP BY
        a.id
	, a.name
	, a.surname ;
       
- Add a column "NumMovies" instead for each actor, no join or
  group by is needed.
  
  This column must be updated in the application anytime an update
  is made to the casts relation. If updates are not frequent, then
  this could be acceptable.
      
- Certain attributes might be duplicated if they are used often
  
  - Example: Store stagename attribute in the casts relation
      
    Queries involving this attribute are now fully answered from
    casts (avoiding a costly join)
    
    Attributes other than stagename might be queried rarely but take a lot
    of space causing the stagename to take up a lot of space
    
    Anytime a new actor is added or stagename is changed, the
    changes must be reflected to the casts relation by updating
      multiple tuples (this may be rare compared to the queries)
      
    The CASTS relation now stores redundant information and is
    larger in size

Query Restructuring
---------------------

- Step 5: Rewrite queries to improve their speed, avoid nested
  queries, use joins whenever possible
  
- Nested queries are hard to optimize. 

- Inner and outer expressions are optimized separately.
  
- For correlated expressions, inner query is executed many times for
  each tuple in the outer expression.
    
- Certain possible optimizations could be missed with a nested query
  (suppose an index for casts on (actorid, filmid) existed)
  

  ::

     SELECT DISTINCT
          m.title
     FROM
          movies m
	  , movieroles mr
     WHERE
          m.id=mr.movieid
	  and exists (
	      select
	        *
	      from
	        actors a  
              where
	        a.surname like '%Bacon'
		and  a.id = mr.actorid);		

  - All queries below are equivalent to the above one

    ::

       -- uncorrelated query is better
       SELECT DISTINCT  
          m.title
       FROM
          movies m
	  , movieroles mr
       WHERE
          m.id=mr.movieid
	  and mr.actorid in (
	      select
	        a.id
	      from
	        actors a  
              where
	        a.surname like '%Bacon');

       -- join query is even better
       SELECT DISTINCT  
          m.title
       FROM
          movies m
	  , movieroles mr
	  , actors a
       WHERE
          m.id=mr.movieid
	  and mr.actorid=a.id
	  and a.surname like '%Bacon';
       
Drops of wisdom
~~~~~~~~~~~~~~~~

- Avoid sorts (distinct, order by, group by, union, except) if
  possible, they are costly
  
- Some queries do not need a distinct or can be rewritten to avoid sorts
  
- Avoid full table scans
  
  - A search on a condition like A <> 3 or A like '%Bacon' might
    result in a table scan
    
  - A search like A in (1,2,4) might be preferable (depending on the
    availability of statistics)
    
- Avoid retrieving tuples into application code, use stored procedures
  and even complicated queries might be preferable to the added
  communication cost

- Use views wisely

  - Even though views are useful in application development, use a
    view in an application that is useful for the given query
    

    ::

       CREATE VIEW together(actorid1, stagename1, actorid2, stagename2) AS
       SELECT a1.actorid, a1.stagename, a2.actorid, a2.stagename
       FROM
           actors a1
	   , actors a2
	   , movieroles mr1
	   , movieroles mr2
       WHERE
           a1.id=mr1.actorid
	   and mr1.movieid=mr2.movieid
	   and a2.id=mr2.actorid
	   and a1.id <> a2.id ;
		  
       SELECT
           t.actorid1
       FROM
           together t
       WHERE
           t.name = 'Kevin'
	   and t.surname = 'Bacon';
       
    - None of the joins are necessary to answer this query. The
      optimizer might miss some faster query plans
      
The use of indices
~~~~~~~~~~~~~~~~~~~

- Indices speed up query, but slow down insert/delete/update operations
  
- A clustered index allows fast access to a range query
  
  - There is only one clustered index per relation
    
  - Databases usually create one for the primary key by default

  - Reconstruction of clustered indices is costly

- Step 6: choose the most useful indices

  - Find the most useful clusters and use them if they are very useful
    for a range of queries and supported by the database
    
  - Next, find the most selective indices to add
    
    - Finally, find indices that might help with index only scans

Clustered Indices
~~~~~~~~~~~~~~~~~~~~

- We can create clustered indices in Postgresql by using an index:

  ::

     create index mr_idx on movieroles(movieid,actorid) ;
     cluster movieroles using mr_idx ;

- Clusters are generated once and are not modified incrementally
  
- You need to recluster periodically if there are frequent updates:

  ::

     cluster movieroles;
     
- The reorganization may be too costly for very large tables.
  
- Create a clustered index for attributes frequently queried with a
  range or has multiple matching attributes for a value

  Above cluster is very useful for finding actors in a movie:

  ::

     select
        a.name
	, a.surname
     from
        movies m
	, movieroles mr
	, actors a
     where
        m.name = 'Harry Potter and the Goblet of Fire'
	and m.id = mr.movieid
	and mr.actorid = a.id;
  
- Clustered indices also provide a sorted order to the relation
  
- Create unclustered indices on attributes with high selectivity
  
  ::

     SELECT A.name, A.surname FROM Actors A WHERE A.gender = 'F';
     
     SELECT
         A.firstname
	 , A.lastname
     FROM
         Actors A
     WHERE
         A.name = 'Kevin'
	 and A.surname ='Bacon';

  - Gender is not a selective condition, but name and surname are.
     
- Index nested loop join is also beneficial when there is a highly
  selective index

  ::

     SELECT
        mr.movieid
     FROM
	actors a, movieroles mr
     WHERE
        a.name = 'Kevin'
	and a.surname = 'Bacon'
	and a.id = mr.actorid;

- For frequently asked queries, indices might be created to allow
  index only searches.
  
  For example, given (name, surname, id) for actors, answering a
  query like one below now requires only an index search for actors.
  

  ::
     SELECT
        mr.movieid
     FROM
        actors a
	, movieroles mr
     WHERE
        a.name = 'Kevin'
	and a.surname = 'Bacon'
	and a.id = mr.actorid;

  - This is in effect a type of vertical partitioning.
    
- For example, given a query like the one below:

  ::

     SELECT
         a2.name
	 , a2.surname
     FROM
         actors a1
	 , movieroles mr1
	 , movieroles mr2
	 , actors a2
     WHERE
         a1.name = 'Kevin'
	 and a1.surname = 'Bacon'
	 and a1.id = mr1.actorid
	 and mr1.movieid = mr2.movieid
	 and a2.id = mr2.actorid;

  for A1, the index is searched in the usual way.

  For A2, the index on(stagename, actorid) can be searched fully
  instead of the relation to speed up the query.


- Indices do not always help reduce the cost of queries:

  - they must be selective

  - they must be significantly smaller in size than the relation they
    are indexing
    
  - they must be used often in queries where they make a difference
    
- Foreign keys introduce hidden costs to updates since they must be
  checked for all updates that relate to them
  
- Count queries can be answered using indices on attributes with a
  "NOT NULL"” constraint (check if the index indices null values)
  
Other hints
------------

- Partition data to multiple disks

  - Place data that is accessed sequentially on its own disk

- Invoke parallel query processing when multiple CPUs are available
  
- Create more detailed statistics (histograms)
  
- Recompute statistics periodically as needed

- Examine the query plans generated by the system and influence them
  as necessary
   
Postgresql Optimizer
----------------------

- Postgresql's CBO (cost-based-optimizer) relies heavily on table
  statistics being available for all tables used in a query.
  
  ::

     analyze;

  will recompute the statistics for all the tables in a database.
  
  Must be run periodically for updated statistics.
  
- You can ask the optimizer to give you the query plan for a query.

  ::

     EXPLAIN query ;

     EXPLAIN
     SELECT
        mr.movieid
     FROM
	actors a, movieroles mr
     WHERE
        a.name = 'Kevin'
	and a.surname = 'Bacon'
	and a.id = mr.actorid;

                                               QUERY PLAN                                          
     ----------------------------------------------------------------------------------------------
      Hash Join  (cost=3302.62..8991.86 rows=2 width=4)
        Hash Cond: (mr.actorid = a.id)
        ->  Seq Scan on movieroles mr  (cost=0.00..4695.07 rows=265107 width=8)
        ->  Hash  (cost=3302.61..3302.61 rows=1 width=4)
              ->  Seq Scan on actors a  (cost=0.00..3302.61 rows=1 width=4)
                    Filter: (((name)::text = 'Kevin'::text) AND ((surname)::text = 'Bacon'::text))
     (6 rows)
     	
Summary
----------

- There are many methods from changing data model, queries and storage
  methods to improve performance.

- Performance must be improved for the whole workload. Compute the
  total cost of all queries multiplied by their frequency before and
  after tuning.

- Tuning is a complex optimization problem due to dependencies between
  different actions. Concentrate on queries that contribute most to
  the workload.

  
