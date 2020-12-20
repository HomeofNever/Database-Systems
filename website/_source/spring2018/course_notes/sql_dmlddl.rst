
SQL - Part 3: Data Definition and Manipulation
==============================================

- A lot of the mechanics for manipulating data builds on SQL select
  syntax. It is crucial to understand SELECT well before learning
  the material in this section.

Overview
----------

- Many data manipulation statements refer to a single table only:
  you can only change one table at a time.

  - If your query needs to access data from another table Y while
    you are modifying table X, you must use a subquery.

  - Review the syntax and examples below carefully to see how this is
    done.

-  Whenever you run a statement that will change the database contents,
   you are running a transaction.

   - If the transaction violates some constraint in the database,
     it will not succeed and your statement will fail.
     
   - Unsuccessful statements should not change the database. See more
     about transactions below.
     

Insert statement
------------------

- Insert a single tuple into a table:

  ::

     INSERT INTO departments
     VALUES(1, 'Physical Magic', NULL, '555-1234');

- Attributes must appear in the values statement in the same
  order they appear in the "create table" statement.

- All attributes must be given a value, even if is null.  

- If you want to only populate some attributes with a value, they
  must be listed:

  ::

     INSERT INTO DEPARTMENTS(id, name, phone)
     VALUES(1, 'Physical Magic', '555-1234');
     
- Any missing attribute is assumed to have a NULL value. 

Insert results of a query to a table
-------------------------------------

-  You can also replace the ``values`` part of insert with a
   query. In this case, all the tuples returned by a query
   are inserted to a table.

   ::

      CREATE TABLE alumni (
          id       int constraint alumni_pk primary key
	  , name   varchar(255) NOT NULL
	  , email  varchar(255) NOT NULL
	  , address varchar(255)
      ) ;

      INSERT INTO alumni (id, name, email, address)
      SELECT
         id, name, email, address
      FROM
         students
      WHERE
         year = extract(year from now());

- There is a shorthand for creating a copy of a table by
  copying both the schema and the tuples from a different table
  that basically extends the above operation:

  ::

     CREATE TABLE alumni as SELECT * FROM students ;

     
Delete statement
-------------------

- You can delete tuples from a table (but leave the table definition
  in the database) using the delete statement.

  ::

     DELETE FROM
         alumni
     WHERE
        email is null ;

- This is an example of a WHERE statement that can only refer to the
  tuples in the table we are deleting from:

  - For each tuple in the table, if the WHERE statement is True,
    then delete the tuple.

- The following will then delete all the tuples in the table:

  ::

     DELETE FROM alumni ;

- If you wanted to completely remove the table, you will then need to
  use the drop statement:

  ::

     DROP TABLE alumni ;


- If you wanted to delete based on a different table, you need a
  subquery:

  ::

     DELETE FROM
        students
     WHERE
        id IN (SELECT id FROM alumni) ;


  - Students cannot be both alumni and student. This is a case
    where IN is needed because you cannot use join here.
     

Update statement
-----------------

- Update statement is very similar to delete.

  - Update tuples by changing the value of one or more attributes.

  - WHERE statement describes which tuples should be updated.


  ::

     UPDATE
         transcript
     SET
         grade = 'I'
	 , gradechanged = now()::date
     WHERE
         semester = 'Fall'
	 and year = 2015
	 and grade is null ;

  Anyone who does not have a grade from last semester should be
  given an incomplete.
   	 
- If there no WHERE statement, all tuples are updated.

- If you need to update based on a different table, you
  must use a subquery.

  ::

     CREATE TABLE s2 as SELECT id FROM students;
     ALTER TABLE s2 ADD totalcredits int ;
     
     UPDATE
        s2
     SET
        totalcredits =
	       (SELECT greatest(0, sum(co.credits)) -- no null values
	        FROM
		   transcript t
		   , courses co
		WHERE -- find courses of the s2 tuple being updated
		   t.student_id = s2.id -- restrict to s2
		   and t.course_id = co.id
		   and t.grade is not null
		   and t.grade <> 'I'
		   and not exists  -- make this is the last time student took this course
		       (select 1
		        from transcript t2
		        where t2.course_id = t.course_id
			      and t2.grade is not null
			      and t2.grade <> 'I'
			      and (t2.year > t.year
               	               or (t2.year = t.year and t2.semester='Fall' and t.semester = 'Spring')))
		);


Transactions
--------------

- A transaction is a series of database operations executed as a logical unit.

- Example::

    Withdraw 100 dollars from account X: 
      Read account value of X into memory
      If greater than 100 then
         subtract 100 from X
         write X back to disk
         commit
     else
         abort

- Transactions have multiple desirable properties. We will
  talk about two in this section:

  - Atomicity: refers to all-or-nothing approach to transactions. Either
    all steps of the transaction succeed, or the transaction leaves the
    database unchanged.

    To accomplish atomicity, the database transaction management
    system keeps track of all changes made and either makes them
    permanent (commit) or rolls them back on abort (rollback).

  - Concurrency: Multiple transactions executing at the same time should
    not have bad effects on each other. Programmers write programs as
    if it is the only program executing at a time.

    
Transactions - Atomicity
------------------------

- Define a transaction start point with START TRANSACTION or BEGIN.

- A transaction either ends successfully with a COMMIT or aborted
  completely with a ROLLBACK.

- A transaction may involve multiple statements and multiple tuples.

  - Whenever an update/delete/insert statement is executed, all
    tuples changed by the statement is part of the same transaction.

  - Sometimes an update statement triggers other operations, for
    example due to constraints attached to foreign keys (see below).

    All these operation become part of the same transaction.

  - If any part of a transaction fails, the whole transaction fails.  

    
Foreign keys
-------------

- A foreign key is a referential integrity constraint:

  - R.A is a foreign key references S.B means that non-null values of
    R.A must be stored in S.B,
    
  - S.B is a unique attribute or a primary key.

- Example

  ::

     CREATE TABLE ABC (
         X int 
         , Y int, 
         , PRIMARY KEY(X,Y)
     ) ;
	 
     CREATE TABLE DEF (
         Z int
         , W int
         , Q int
         , PRIMARY KEY Z
         , FOREIGN KEY (Z,W) 
           REFERENCES ABC(X,Y)
           ON DELETE CASCADE
           ON UPDATE SET NULL
     ) ;

- This means that DEF(Z,W) can be null (as there is no not null
  constraint), but if they have a value, the value must exit in DEF.

- When a tuple from ABC is deleted, tuples that reference this tuple
  are also deleted (CASCADE).

- If the primary key for a tuple in ABC is updated, then the
  corresponding tuples in DEF are set to null.

- If there is no corresponding ON DELETE or ON UPDATE actions, the
  default behavior is "RESTRICT". In this case, an update/delete from
  ABC will fail if there are any tuples in DEF that reference it.
  
- All these cascade and set null events become part of the same
  transaction as the triggering update/delete/insert.

Constraint checking
-------------------

- All constraints are checked immediately, i.e. as soon as the
  relation they are attached to is changed (foreign keys are attached
  to the referenced relation).

- This is not desirable for cyclic constraints:

  Example: check for egg a chicken exists and check for chicken an egg exists

- You can defer checking of constraints to the end of the transaction:

  ::
     
     FOREIGN KEY (Z,W) REFERENCES ABC(X,Y)
     DEFERRABLE INITIALLY DEFERRED

Other constraints
-------------------

- NOT NULL: checks that the values stored for an attribute should not
  be null

- CHECK: checks for an attribute or tuple, the values satisfy a
  condition (anything that can be written in the WHERE clause of a
  query that refers to the attributes in the given table only)

- Example
  
  ::
     
     CREATE TABLE class (
        id int PRIMARY KEY
        , code  CHAR(4)
        , name VARCHAR(50) NOT NULL
        , semester VARCHAR(5) CHECK (semester in ('Fall', 'Spring','Summer'))
        , year INT CHECK (year > 1990)
        , CHECK (code IS NOT NULL OR name = 'MISC')
     ) ;

- The constraint:

  ::

     CHECK (code IS NOT NULL OR name = 'MISC')
  
  is checked when a new tuple is inserted into class or when it is updated.

Assertions
-------------

- Integrity constraints can be expressed in SQL using assertions.

  ::
     
     CREATE ASSERTION assertionName CHECK  ( … )
     
- Assertions are created for a database, i.e. for all tables in a
  schema. They are evaluated anytime a table in the schema is changed.

- The check clause of an assertion is similar to the WHERE clause,
  except there is no FROM clause and relations.

- Anytime a change (INSERT/UPDATE/DELETE) in a table violates an
  assertion, then the transaction causing the change is aborted.

- Assertions are part of SQL standard, but they are not implemented
  in Postgresql.

- Whenever any transaction violates any existing assertion in the
   database, the transaction is aborted and all the changes are
   rolled back.

Assertion Examples
------------------

- The max_enrollment for a class cannot be larger than the seating
  capacity of the classroom assigned to the class.

  ::
     
     CREATE ASSERTION maxClassSize
     CHECK NOT EXISTS (
         SELECT
	     1
         FROM
	     classes c
	     , classrooms cr
         WHERE
	     c.classroom_id = cr.id
             and cr.numseats <
	         (SELECT
		     count(*)
	          FROM
		     transcript t
		  WHERE
		     t.course_id = c.course_id
		     and t.semester = c.semester
		     and t.year = c.year
		     and t.section = c.section
     ) ) ;

- Students cannot take a course without completing the prerequisites
  of that course.

  ::

     CREATE ASSERTION mustHavePrereq
     CHECK NOT EXISTS (
          SELECT
	      *
          FROM
	      transcript t1
	      , requires r
          WHERE
	      t1.course_id = r.course_id
	      and NOT EXISTS (
                  SELECT
		      *
                  FROM
		      transcript t2
                  WHERE
		      t2.course_id = r.prereq_id
                      and t2.student_id = t1.student_id
		      and t2.grade in (‘A’,’B’,’C’,’D’)
        ) ) ;
     

Triggers
---------

- Assertions may be costly to implement for databases, because they
  must be checked for any insert/update/delete statements.

- As a result, assertions may incur a considerable performance
  penalty.

- Triggers allow the violations to be checked for certain actions:

  ::

     CREATE TRIGGER xyz AFTER INSERT ON transcript

- Triggers can define what are violations programmatically.     

- Furthermore, triggers may describe what must happen if there is
  a violation, instead of simply failing the transaction.

- We will see transaction in detail in the next section.


Transactions - Isolation
--------------------------

- Isolation principle says that if one transaction executes completely
  before the other, than its result is acceptable.

- Hence, any serial ordering of transactions results in an acceptable
  database state.

- There is an implicit assumption that transactions are complete
  units of execution and are implemented correctly.

- Let us see an example of what can go wrong if the database does
  not guarantee serializability.

  Given two transactions, T1 and T2 that access the same data X
  (tuple or attribute)

  ::

     T1: read(x), x++, write(x), read(y), y--, write(y)
     T2: read(x), x--, write(x)

  Assume read/write are disk operations, reading/writing data to
  the database. The increment/decrement are operation that take
  place in memory.

- Suppose X=10, Y=10

- Isolation says that if one transaction executes completely before
  the other, than its result is acceptable.

- After: T1->T2 or T2->T1, we have: X=10,Y=9. See for example:

  =======   =========  =========
  Time      T1         T2
  =======   =========  =========
  1         read(x)
  2         x++
  3         write(x)           
  4         read(y)           
  5         y--
  6         write(y)
  7                    read(x)
  8                    x--
  9                    write(x)
  =======   =========  =========

  Which gives x=10, y=9.

- Instead, assume the following set of operations take place in
  the following order of time:

  =======   =========  =========
  Time      T1         T2
  =======   =========  =========
  1         read(x)
  2         x++
  3                    read(x)
  4                    x--
  5         write(x)
  6         read(y)
  7                    write(x)
  8         y--
  9         write(y)
  =======   =========  =========

  Since T2 reads the value of x before it is written, T1 and T2
  read the same value of x.

  The final result of this database is X=9, Y=9.

  There is no equivalent serial execution that gives this result,
  which is a problem.

  
- Let us see a different execution order:

  =======   =========  =========
  Time      T1         T2
  =======   =========  =========
  1         read(x)
  2         x++
  3         write(x)           
  4                    read(x)           
  5                    x--
  6         read(y)
  7                    write(x)
  8         y--
  9         write(y)
  =======   =========  =========

  This one gives the result x=10, y=9, which is equivalent
  to a serial execution.

Serializability
-----------------
- Make sure that even though operations of different transactions may
  be interleaved, the resulting state is equivalent to the result of
  some serial execution.

Dirty Read
-----------------------

- Dirty read: dirty read is a value written by an uncommitted transaction.
  
  =======   =========  =========
  Time      T1         T2
  =======   =========  =========
  1         read(x)
  2         x++
  3         write(x)           
  4                    read(x)           
  =======   =========  =========

  Here, value read by T2 is written by T1. If T1 is not yet committed,
  we must not allow T2 to commit either.

  If T1 aborts, then T2 must also be aborted (leading to cascading
  aborts).

  
SQL Levels of isolation
------------------------

-  Four levels, each one overcomes a problem that may happen in the
   previous level

   ======================  ===========================================
   ISOLATION LEVEL         POTENTIAL PROBLEM
   ======================  ===========================================
   READ UNCOMMITTED        Dirty data read
   READ COMMITTED          Repeated reads may give different results
   REPEATABLE READ         Phantom update
   SERIALIZABLE            None of the above
   ======================  ===========================================

- As each level is more restrictive, fewer transactions may run
  concurrently.

- Most DBs do not allow READ UNCOMMITTED or force a transaction at
  this level to be read only.

- A READ COMMITTED transaction allows other transactions to read/write
  an item after the transaction is done reading/writing it. Hence,
  if the same value is read again, its value may be different.

- REPEATABLE READ does not allow the data to be changed by another
  transaction.

  But, it is possible that new tuples that may be relevant to a
  transaction are inserted or changed while the transaction is
  executing.

  Example: Find number of students in class CSCI-4380.

  While counting, none of the existing students may drop the class.

  But, new students may be added. This is called phantom update.

- SERIALIZABLE does not allow phantom updates either. It is the
  most restrictive method, often requiring monitoring the tuples
  that may effect a query/insert/update condition.

- Postgresql implementation does not exactly correspond to these
  levels. We will talk about these in detail when we discuss
  transaction management.

- Here is an example with transaction isolation levels:

  ::

     START TRANSACTION ;
     SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
     INSERT INTO T1 SELECT NAME FROM T2 ;
     INSERT INTO T1 SELECT NAME FROM T2 ;
     COMMIT ;

- Note that transactions may commit or rollback either
  programmatically or by external events: table constraint violations
  or other transaction management system events like resolution of
  deadlocks or time outs.

  What is the result of the following transaction?
  
  ::

     START TRANSACTION ;
     SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
     INSERT INTO T1 SELECT NAME FROM T2 ;
     INSERT INTO T1 SELECT NAME FROM T2 ;
     ROLLBACK ;
  
