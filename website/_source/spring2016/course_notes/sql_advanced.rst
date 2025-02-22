

SQL - Part 2: Advanced Features
===============================

- In this lecture, we will learn more advanced features of SQL.

- Examples database to be used in this lecture is given in SQL here:

  See :download:`example database to be used <databases/university.sql>`.


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

  - Do not join with relations unnecessarily.
  - Do not sort (order by) or remove duplicates (distinct) unless it
    is needed.

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

- Find for each student, total number of classes

  ::

     SELECT
        s.id
	, s.name
	, count(t.student_id) as numclasses
     FROM
        students s
	left join transcript t
        on s.id = t.student_id
     GROUP BY
        s.id
	, s.name;

  As count(attr) counts the total number of values, students
  with no classes will have zero classes.

  If we used inner join, we would have elimited all students with
  zero classes as they would not join with transcript.

- Find faculty who did not teach any classes

  ::

     SELECT
        f.id
	, f.name
     FROM
        faculty f
	left join classes c
	on f.id = c.instructor_id
     WHERE
        c.instructor_id is null;
     
-  Find classes with no students. Return semester, year, section and
   course name.

   ::

      SELECT
         co.crsname
	 , c.course_id
	 , c.semester
	 , c.year
	 , c.section
      FROM
         (classes c
	 left join transcript t
	 on c.course_id = t.course_id
	    and c.semester = t.semester
	    and c.year = t.year
	    and c.section = t.section),
	 courses co
      WHERE
         t.course_id is null
	 and co.id = c.course_id;

	 
   This works because for each class, there is a course tuple.
   Otherwise, you would need to do a left join with the next table
   as well.

Anonymous relations
---------------------

- A query can be treated like a relation in the from clause

  It is treated like a virtual relation:

  ::

    SELECT
       f.id
       , f.name
       , f2class.numclasses
       , count(*) as numstudents
    FROM
       ( SELECT
             instructor_id AS id
	     , count(*) as numclasses
	 FROM
	     classes
	 GROUP BY
	     instructor_id
	 HAVING
	     count(DISTINCT year) >= 2
       ) as f2class
       , classes c
       , transcript t
       , faculty f
    WHERE
       f2class.id = c.instructor_id
       and t.course_id = c.course_id
       and t.semester = c.semester
       and t.year = c.year
       and t.section = c.section
       and f.id = c.instructor_id
    GROUP BY
       f.id
       , f.name
       , f2class.numclasses;

  The inner query allows us to find faculty who taught in at
  least two years and total number of classes they taught.
  We can then use this information in the main query as if it was
  a real relation.

  This query would be very hard to write without an anonymous
  relation as we cannot count for different types of things with
  a single group by.

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

   You can use a scalar query as if it was a number.
   
   ::

      SELECT count(*) FROM classes WHERE instructor_id = 4;

      count 
      -------
      5
      (1 row)


      SELECT
         instructor_id
	 , count(*)
      FROM
         classes c
      GROUP BY
         c.instructor_id
      HAVING
         count(*) >= 5;
       

   Let's rewrite this query by substituting the above query for
   number 5 in the having clause.

   ::

       SELECT
         instructor_id
	 , count(*)
       FROM
         classes c
       GROUP BY
         c.instructor_id
       HAVING
         count(*) >= (SELECT count(*) FROM classes WHERE instructor_id = 4);


Comparisons involving sets/bags
--------------------------------

-  Many expressions in the WHERE clause (or HAVING) can compare a
   value against a SET

   ::

      WHERE grade IN ('A', 'B')
      WHERE year NOT IN (2015, 2016)
      

-  Substitute a query for the set: Find all faculty who never
   taught a class.

   ::

      SELECT
         f.id
	 , f.name
      FROM
         faculty f
      WHERE
         f.id NOT IN (SELECT instructor_id FROM classes) ;
   

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
          students
      WHERE
          EXISTS (SELECT 1
	          FROM classes
		  WHERE semester='Spring' and year=2016);

   This is a kind of stupid query: if there is any class offered in
   Spring 2016, return all students. Otherwise, return no students.

-  Since it does not matter what we return in EXISTS/NOT EXISTS
   conditions (we only care whether a tuple is returned or not), we
   can return something simple like an integer, instead of a
   relation column.
      
Correlated Subqueries
-----------------------
   
-  More interesting queries involve correlated subqueries.
   
-  Find faculty with no classes:

   ::

      SELECT
          f.id
	  , f.name
      FROM
          faculty f
      WHERE
          NOT EXISTS
	  ( SELECT 1 FROM classes c WHERE c.instructor_id = f.id ) ;
	  

   For each faculty tuple f, execute the inner subquery to find all
   tuples for this faculty. If there is no such tuple, then return
   tuple f.

   - Outer query: faculty f
   - Inner query: classes c

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
        f.id
        , f.name
     FROM
        faculty f
     WHERE
        NOT EXISTS
	( SELECT
	     1
	  FROM
	     classes c
	     , faculty f
	  WHERE
	     c.instructor_id = f.id ) ;

  This query will return a very different result than the correct
  query as inner faculty f overwrites the outer faculty f.

  For each faculty tuple, execute the inner query independently.
  If it returns no tuples, return the faculty tuple. Hence: this
  will return no faculty tuples.
    
     
Examples
~~~~~~~~~~

-  Find faculty teaching at most 3 courses:

   ::

      SELECT
         f.id
	 , f.name
      FROM
         faculty f
      WHERE
         3 >= (SELECT count(*) FROM classes c WHERE f.id=c.instructor_id);

   Note that while this is a correct query, it is likely more
   efficient to use a group by statement for the same purpose:

   ::

      SELECT
         f.id
	 , f.name
      FROM
         faculty f
	 LEFT JOIN classes c
	 ON f.id = c.instructor_id
      GROUP BY
         f.id
	 , f.name
      HAVING
         count(c.instructor_id) <= 3;

  Be careful: the query would not be correct without a left join. Why?

- Scalar queries can also be correlated (though use this as a last
  resort as well):

  ::

     SELECT
        s.id
	, s.name
	, (SELECT count(*)
	   FROM transcript t
	   WHERE t.student_id=s.id AND t.grade='A') as numAs
     FROM
        students s ;

  Remember: this is not likely an efficient way to write this query.

Examples
-----------------

- We will finish section with a few complex queries.

  A problem in using the transcript relation is that a student might
  take a class more than once. However, their grade from the last time
  they took the class is the one that counts.

  When computing credits completed, we need to return a single tuple
  for each course that corresponds to the last valid grade for that
  class.

  ::

     SELECT
        s.id
	, s.name
	, count(t.course_id) as coursescompleted
     FROM
        students s
	LEFT JOIN transcript t
	ON s.id = t.student_id
	   AND t.grade IS NOT NULL
	   AND t.grade <> 'I'
     WHERE
        NOT EXISTS
	   ( SELECT 1
	     FROM
	        transcript t2
	     WHERE
	        t2.student_id = t.student_id
	        AND t2.course_id = t.course_id
		AND (t2.year < t.year OR
		     (t2.year = t.year
		      AND t2.semester = 'Spring'
		      AND t.semester='Fall'))
	    )
     GROUP BY
        s.id
	, s.name ;


FOR ALL Queries
---------------

- What is we wanted to find students who have taken a class from
  all the professors in the database.

- This is a complex query: we want to check that the set of professors
  for a student is equivalent to the set of all professors.

  In relational algebra, this query would need two set subtractions.

  We can represent this query logically as follows:

  ::

     Find students who took a class from ALL professors in the database.

     Find students s such that
          there does not exist a professor f such that
	       s did not take a class from f
	       (or there does not exists a tuple in transcript
	        for s and f)

-  SQL query will also require two subqueries:

   ::

      SELECT
         s.id
	 , s.name
      FROM
         students s
      WHERE
         NOT EXISTS
	    (SELECT 1
	     FROM faculty f
	     WHERE NOT EXISTS
	           (SELECT 1
		    FROM transcript t, classes c
		    WHERE
		        t.student_id = s.id
			AND c.instructor_id = f.id
			AND c.course_id = t.course_id
			AND c.semester = t.semester
			AND c.year = t.year
			AND c.section = t.section));



-  Do we really need this level of complexity? Can we do this
   using a count?

   ::

      Return each student if the number of different
      faculty they took classes with is equal to the number
      of different faculty in the database.


   Let's write this expression:

   ::

      SELECT
         s.id
	 , s.name
      FROM
         students s
	 , transcript t
	 , classes c
      WHERE
         s.id = t.student_id
	 AND t.course_id = c.course_id
	 AND t.semester = c.semester
	 AND t.year = c.year
	 AND t.section = c.section
      GROUP BY
         s.id
	 , s.name
      HAVING
         count(DISTINCT c.instructor_id) =
	        (SELECT count(*) FROM faculty) ;
			
- Not only this query is simpler to write, it is likely much more
  efficient given it has no correlated subqueries.

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
  
