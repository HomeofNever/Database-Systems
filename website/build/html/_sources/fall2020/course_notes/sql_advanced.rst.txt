

SQL - Part 2: Advanced Features
===============================

- In this lecture, we will learn more advanced features of SQL.

- Examples database to be used in this lecture is given in SQL here:

  See :download:`example database to be used <databases/baking_database.sql>`.


Overview
--------

- Remember that while SQL is a standard, there are still differences
  in implementations of it.

  - Writing queries that do not rely on specific features results in
    portable applications.

  - However, you cannot deny that some constructs may simplify your
    queries and performance. So, it is important to decide when to use
    a specific method to write a query.

- Remember: a query is not an algorithm. It is for the most part
  a logical statement of what you are interested in. 

  - Often, there are multiple algorithms to implement it.
  - Most DBMSs feature state of the art query optimizers (QOPT) that 
    choose the lowest cost algorithm for a given query and database.
  - QOPT engines are very sophisticated, often operate better than
    even expert human judgment. 
  - So, instead of trying to optimize your queries, 
    you can try to make your queries easy to optimize: simple queries
    are better.

- Once you become sophisticated in a specific DBMS, you may learn
  specific weaknesses and you can develop strategies to adopt for
  that. We will discuss some.

- Finally, you should still follow some very simple guidelines:

  - Do not join with a relation if it is not needed for your query.
  - Do not sort (order by) or remove duplicates (distinct) unless it
    is necessary.

Outer Join
---------------

- A INNER JOIN B: inner join selects tuples that satisfy a join condition,
  eliminates all tuples that do not satisfy the join condition. A is
  called the left operand and B is the right operand of the join
  operation.
  
- A LEFT OUTER JOIN B returns all tuples in the inner join as well as
  the tuples in A that do not join with any tuples in in B.
  
- A RIGHT OUTER JOIN B returns all tuples in the inner join as well as
  the tuples in B that do not join with any tuples in in A.
  
- A FULL OUTER JOIN B returns all tuples in the inner join as well as
  the tuples from A and B that do not participate in the inner join.

  - You can also use terms: JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN
  

Inner vs. outer join.
-------------------------

-  Given R(A,B) and S(B,C) with the following contents:

====  ====
A     B
====  ====
a1    b1
a2    b2
====  ====

====  ====
B     C
====  ====
b1    c1
b3    c3
====  ====

-  We get the following results:

   ::

      SELECT R.A, R.B, S.B, S.C
      FROM R JOIN S ON R.B=S.B;

      
   ====  ====  ====  ==== 
   A     B     B     C
   ====  ====  ====  ====
   a1    b1    b1    c1
   ====  ====  ====  ====

   ::

      SELECT R.A, R.B, S.B, S.C
      FROM R LEFT JOIN S ON R.B=S.B;

      
   ====  ====  ====  ==== 
   A     B     B     C
   ====  ====  ====  ====
   a1    b1    b1    c1
   a2    b2    null  null       
   ====  ====  ====  ====


   ::

      SELECT R.A, R.B, S.B, S.C
      FROM R RIGHT JOIN S ON R.B=S.B;

      
   ====  ====  ====  ==== 
   A     B     B     C
   ====  ====  ====  ====
   a1    b1    b1    c1
   null  null  b3    c3
   ====  ====  ====  ====

   
   ::

      SELECT R.A, R.B, S.B, S.C
      FROM R FULL JOIN S ON R.B=S.B;

      
   ====  ====  ====  ==== 
   A     B     B     C
   ====  ====  ====  ====
   a1    b1    b1    c1
   a2    b2    null  null       
   null  null  b3    c3
   ====  ====  ====  ====


- We can use the fact that tuples that do not match have
  null values for the join.


Outer join examples:
~~~~~~~~~~~~~~~~~~~~~~

- For each baker, find the total number of times they were a favorite.

  ::

     SELECT
        b.baker
	, count(f.baker) as numfavorites
     FROM
        bakers b
	   left join favorites f
	   on b.baker = f.baker
     GROUP BY
        b.baker ;
	
  For bakers with no favorite tuples, f.baker will be null. So, when
  we count f.baker values, the count will be zero for these
  bakers.

  If we used inner join, we would have elimited all bakers with
  zero favorite tuples as they would not join with favorites.

     
-  Find bakers who were never a favorite.

  ::

     SELECT
        b.baker
     FROM
        bakers b
	   left join favorites f
	   on b.baker = f.baker
     WHERE
        f.baker IS NULL;      

	 
   This works because if a baker has no matching tuple in favorites,
   then the f.baker attribute would be null.

- For each baker, find how many times they won the technical challenge.

  Note that we would like to use left join as in the previous case,
  but not with the whole technicals table but only the tuples where
  rank is 1.

  ::

     SELECT
        b.baker
	, count(t.rank) as numwins
     FROM
        bakers b
	   left join technicals t
	   on b.baker = t.baker
	      and t.rank = 1
     GROUP BY
        b.baker;

Anonymous relations
---------------------

- A query can be treated like a relation in the from clause

  It is treated like a virtual relation:

  ::

     
    SELECT
       t.baker
       , count(t.rank) as numtophalf
    FROM
       ( SELECT
             episodeid 
	     , count(*) as numbakers
	 FROM
	     technicals
	 GROUP BY
	     episodeid
       ) as epnum
       , technicals t
    WHERE
       t.episodeid = epnum.episodeid       
       and t.rank < epnum.numbakers/2
    GROUP BY
       t.baker ;

  The inner query allows us to find how many bakers competed in each
  episode. We can then use this information in the main query as if it
  was a real relation, and find how many times a baker performed in
  the top half of the technical challenges.

  This query would not be possible to write without an anonymous
  relation as we cannot count for different types of things (bakers
  for episodes and episodes for bakers) with a single group by.

- Find the maximum number of people eliminated in an episode:

  ::

     SELECT max(numeliminated)
     FROM
         (SELECT -- number of people eliminated in each episode
	     count(*) as numeliminated
          FROM
	     results
          WHERE
	     result='eliminated'
          GROUP BY
	     episodeid 
	  ) as elim;


- Be careful: Do not use any anonymous relations to make it
  simpler to write/read the query.

  ::

     SELECT
        S.d
     FROM
        (SELECT a.* FROM R WHERE b>5) as newR
	, S
     WHERE
        S.c = newR.c;
    
  Anonymous relation is not really necessary here. The same query
  can be written with a simple join:

  ::

     SELECT S.d FROM R,S WHERE R.b>5 and S.c=R.c;
	

  When using an anonymous view, query optimizer may miss certain
  optimizations, especially in older DBMS.

  
  
Scalar Queries
-----------------

-  Any query that returns a single number with an aggregate function
   is called a scalar query.

   You can use a scalar query as if it was a number. We first find the
   biggest drop in ratings between two episodes:
   
   ::

      SELECT
         max(e2.viewers7day-e1.viewers7day)
      FROM
         episodes e1
	 , episodes e2
      WHERE
         e2.id = e1.id+1;

      max  
      -------
      0.84
      (1 row)

   Now we find who was eliminated in this episode (or episodes if
   there is more than one with the same drop):

   ::
      
      SELECT
         r.baker
      FROM
         episodes e1
	 , episodes e2
	 , results r
      WHERE
         e2.id = e1.id+1
	 and e2.viewers7day-e1.viewers7day = 0.84
	 and r.episodeid = e1.id
	 and r.result = 'eliminated';

      baker  
      --------
      Briony
      (1 row)

   We can write the same query by simply substituting the first query
   for the constant 0.84:

   ::

       SELECT
          r.baker
       FROM
          episodes e1
 	  , episodes e2
	  , results r
       WHERE
          e2.id = e1.id+1
	  and e2.viewers7day-e1.viewers7day =
	                   (SELECT max(e2.viewers7day-e1.viewers7day)
                            FROM episodes e1, episodes e2 WHERE e2.id = e1.id+1)
	  and r.episodeid = e1.id
	  and r.result = 'eliminated';


	  
Comparisons involving sets/bags
--------------------------------

-  Many expressions in the WHERE clause (or HAVING) can compare a
   value against a SET

   ::

      WHERE hometown IN ('London','Bristol')
      WHERE baker NOT IN ('Imelda','Luke')

-  Substitute a query for the set: Find bakers who were never eliminated.

   ::

      SELECT
         baker
	 , fullname
      FROM
         bakers
      WHERE
         baker NOT IN (SELECT baker FROM results WHERE result = 'eliminated');
   
- You can write equivalent queries using EXCEPT and LEFT JOIN.

Set Comparison Operators
--------------------------

-  There are many set comparison operators that can be used in
   queries. The inner query must return a single column for this to
   work.

   Some useful operations:

   ::
      
      value IN (QUERY)
      value NOT IN (QUERY)
      value > ANY (QUERY)
      value >= ALL (QUERY)
      value > ALL (QUERY)
      value = ANY (QUERY)   --> same as IN
      value <> ALL (QUERY)  --> same as NOT IN

-  You can also write expressions that check whether a query returns
   any tuples at all:

   ::

      EXISTS (QUERY) => True if Query returns at least one tuple
      NOT EXISTS (QUERY) => True if Query returns no tuples


-  Examples:

   ::

      5 IN (1,2,3,4)       FALSE
      5 NOT IN (1,2,3,4)   TRUE
      2 IN (1,2,3,4)       TRUE
      EXISTS (1,2,3,4)     TRUE
      NOT EXISTS (1,2,3,4) FALSE
      NOT EXISTS ()        TRUE
      5 <ALL (1,2,3,4)     FALSE
      5 >ALL (1,2,3,4)     TRUE

-  Example:

   ::

      SELECT
          *
      FROM
          bakers
      WHERE
          EXISTS (SELECT 1
	          FROM signatures
		  WHERE lower(make) LIKE '%cardamom%');

   This is a kind of stupid query: if there is any make with cardamom,
   we will return all bakers. Otherwise, we return no students.

-  Since it does not matter what we return in EXISTS/NOT EXISTS
   conditions (we only care whether a tuple is returned or not), we
   can return something simple like an integer, instead of a
   relation column.
      
Correlated Subqueries
-----------------------
   
-  More interesting queries involve correlated subqueries.
   
-  Find bakers who never won a technical challenge:

   ::

      SELECT
          b.baker
	  , b.fullname
      FROM
          bakers b
      WHERE
          NOT EXISTS
	  ( SELECT 1 FROM technicals t WHERE t.baker = b.baker and t.rank=1 ) ;
	  
   For each baker tuple b, execute the inner subquery to find all
   technical tuples for this baker with rank 1. If there is no such
   tuple, then return tuple b.

   - Outer query: bakers b
   - Inner query: technicals t

-  Scope of variables:
   
   - The inner query can reference any tuple value in the outer query
     (from the FROM clause), treating these values as constants for
     the inner query.

   - The outer query cannot access the variables of the inner query.
   - If the iner query rewrites an alias from the outer query, then
     the closest definition is used.


Common mistake when using a nested subquery
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Rewrite your own alias in the inner subquery
  
  ::

       SELECT
          b.baker
	  , b.fullname
       FROM
          bakers b
       WHERE
          NOT EXISTS
	  ( SELECT 1 FROM technicals t, bakers b
	    WHERE t.baker = b.baker and t.rank=1 ) ;

  This query will return a very different result than the correct
  query as inner baker b overwrites the outer baker b.

  For each baker tuple, execute the inner query independently.  If it
  returns no tuples, return the baker tuple. Hence: this will return
  no baker tuples as there is at least one tuple in the inner query.
    
     
Examples
~~~~~~~~~~

-  Find bakers who won at least 3 technical challenges:

   ::

      SELECT
         b.baker
	 , b.fullname
      FROM
         bakers b
      WHERE
         1 >= (SELECT count(*) FROM technicals t
	       WHERE t.baker=b.baker and t.rank=1);

   Note that while this is a correct query, it is likely more
   efficient to use a group by statement for the same purpose:

   ::

      SELECT
         b.baker
	 , b.fullname
      FROM
         bakers b
	   LEFT JOIN technicals t
	   ON b.baker = t.baker and t.rank=1
      GROUP BY
         b.baker
	 , b.fullname
      HAVING
         count(t.baker) <= 1;

  Be careful: the query would not be correct without a left join. Why?

- Scalar queries can also be correlated (though use this as a last
  resort as well):

  ::

     SELECT
        e.id
	, count(*) as numeliminated
	, (SELECT count(*) FROM favorites f WHERE f.episodeid = e.id)
	  as numfavorites
     FROM
        episodes e
	, results r
     WHERE
        e.id = r.episodeid
	and r.result = 'eliminated'
     GROUP BY
        e.id;
     

  Remember: this is not likely an efficient way to write this
  query. Can you write the same query without a correlated subquery in
  SELECT?

Examples
-----------------

- We will finish section with a few complex queries.

  Suppose we wanted to find if a baker did not compete in a specific
  episode. We would need find when they were eliminated and then see
  if there was an episode before their elimination in which there was
  no tuple for them competing in one of the challenges.

  ::
     
     SELECT DISTINCT
         b.baker
         , b.fullname
	 , e.id
     FROM
         results r
        , bakers b
        , episodes e
     WHERE
        r.result = 'eliminated'
        and r.baker = b.baker
        and e.id < r.episodeid  -- an episode before they were eliminated
        AND NOT EXISTS
            (SELECT 1 FROM signatures s
             WHERE  s.episodeid = e.id and s.baker = b.baker);  


- Since we can find the absence of a tuple with left join too, how
  about we look for an alternate way to write this query with left
  join. But we need to be careful to set the relation carefully that
  will left join. Here is one:

  ::

      SELECT DISTINCT
          b.baker
          , b.fullname
  	  , e.id
      FROM
          bakers b join results r
	    on r.baker = b.baker and r.result='eliminated'
 	    join episodes e
	       on e.id < r.episodeid
               left join signatures s
	          on s.episodeid = e.id and s.baker = b.baker
      WHERE
          s.baker is null;
     

FOR ALL Queries
---------------

- What is we wanted to find bakers who competed in all the episodes of
  the show.

- This is a complex query: we want to check that the set of all
  episodes that the baker competed in is equal to the set of all
  episodes that exist.

  In relational algebra, this query would need two set subtractions.

  We can represent this query logically as follows:

  ::

     Find bakers who competed in all episodes:

     Find bakers b such that
          there does not exist an episode e such that
	       b did not take compete in episode e
	       (or there does not exists a tuple in signatures (or showstoppers or technicals)
	        for b and e)

-  SQL query will also require two subqueries:

   ::

      SELECT
         b.baker
	 , b.fullname
      FROM
         bakers b
      WHERE
         NOT EXISTS
	    (SELECT 1
	     FROM episodes e
	     WHERE NOT EXISTS
	           (SELECT 1
		    FROM
		        signatures s
		    WHERE
			s.episodeid = e.id 
			AND s.baker = b.baker));

-  Do we really need this level of complexity? Can we do this
   using a count?

   ::

      Return each baker if the number of different
      episodes they competed in is equal to the number
      of different episodes in the database.


   Let's write this expression:

   ::

      SELECT
         b.baker
	 , b.fullname
      FROM
         bakers b
	 , signatures s
      WHERE
         b.baker = s.baker
      GROUP BY
         b.baker
	 , b.fullname
      HAVING
         count(*) = (SELECT count(*) FROM episodes) ;
			
- Not only this query is simpler to write, it is likely much more
  efficient given it has no correlated subqueries.

WITH Statement (newer form of anonymous relations)
----------------------------------------------------

- Postgresql implements the WITH statement, part of SQL standard. In
  its simplest form, WITH acts like anonymous relations. But in
  reality it can do a lot more.

- The following is the identical query from above written using
  WITH clause:

  ::

     WITH maxdrop AS
       ( SELECT max(e2.viewers7day-e1.viewers7day) as drop
         FROM episodes e1, episodes e2 WHERE e2.id = e1.id+1)
      SELECT
          r.baker
      FROM
          episodes e1
 	  , episodes e2
	  , results r
	  , maxdrop m
      WHERE
          e2.id = e1.id+1
	  and e2.viewers7day-e1.viewers7day = m.drop
	  and r.episodeid = e1.id
	  and r.result = 'eliminated';


- However, anonymous relations can only be used in FROM  while
  relations generated using WITH can be used in any SQL statement,
  including in subsequent WITH statements.


  ::

       WITH dropval AS
       ( SELECT
             e1.id
	     , max(e2.viewers7day-e1.viewers7day) as drop
         FROM
	     episodes e1
	     , episodes e2
	 WHERE
	     e2.id = e1.id+1
	 GROUP BY
	     e1.id ),
        maxdropval AS
	( SELECT max(drop) as maxdrop FROM dropval)
        SELECT
            r.baker
        FROM
     	   results r
	   , dropval d
	   , maxdropval m
        WHERE
	   r.episodeid = d.id
	   and r.result = 'eliminated'
	   and d.drop = m.maxdrop ;

- In this case, `maxdropval` is referring to a query above it in the
  WITH statemnt. You cannot do this in anonymous queries. Even though
  `maxdropval` builds on `dropval`, you can use both in the FROM
  statement below.

- While WITH statement is quite powerful as a construct, be very
  careful to use it only if is helps you write a query that is
  cumbersome or very ineffecient to write using regular SQL. You can
  do this by checking the cost of different queries. Find the cost of
  queries by using cost estimators or by load testing and check if it
  results in cost savings.

  Do not allow the WITH statements to make SQL more procedural, this
  may result in the optimizer missing some crucial query
  optimizations.


- We will reexamine WITH when we look at advanced SQL features.       
      
Summary
------------

- Most queries that use IN or EXISTS can be rewritten using simple
  joins. Joins are much easier to optimize.
  
- Set subtraction usually can be expressed using NOT IN or NOT EXISTS.
  
- Using anonymous relations in the from clause may cause the optimizer
  to miss some optimizations. Simpler the query, the better it is.

- There is a subtle difference on the syntax of the two statements:

  ::

     Attribute NOT IN (select statement)
     NOT EXISTS (select statement)

- For all queries usually require two NOT EXISTS.

- SQL aggregates and outer joins are powerful constructs for
  formulating complex queries, even those involving some sort of
  negation.
  
