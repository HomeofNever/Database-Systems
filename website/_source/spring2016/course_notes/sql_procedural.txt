
SQL - Procedural Programming
=============================

Overview
---------

- Queries and expressions in SQL are ideal for large set-at-a-time
  operations:

  - Operations that need to search the whole relation to answer a
    complex combination of tuples.

  - Using SQL allows database to use the query optimizer to find the
    best query execution plan for the query.

- However, SQL is not efficient for some programming tasks:

  - Sequence of code: A block of queries that must be executed in an order
  - Conditionals: if/then/else statements (some simple ones can be
    handled, but cannot be combined with sequence of code
  - Loops 
  - Store values in and use values from program variables
  - Error handling


Example Program
---------------

- We will see an example program that is hard to write using an SQL
  query, but trivial with a procedural language.

- Find the top 3 most frequent y for each x in table R(x,y,z).

  - Not very easy!

  - However, suppose we have a query:

    ::
       
       SELECT x,y, count(*) num FROM R GROUP BY x,y ORDER BY x,y, num;
       
    Now, we can write a simple program to compute this as follows:
  
    ::

       Algorithm Top 3 y for each x:
          Run query:
	       SELECT x,y, count(*) num
	       FROM R
	       GROUP BY x,y
	       ORDER BY x,y, num;
	  In a loop read each tuple such that:
	      if a new x is found:
	          read the next three y values
		  (error handling if less than three y values are found)
		  skip remaining x values

Procedural SQL
----------------

- To enable the use of SQL for costly queries, while making it
  possible to write code/procedures on top of it, databases support a
  number of options.

- The options belong in two main options:  

  - Server side
  - Client side

Server side
~~~~~~~~~~~~~

- Languages make it possible to define procedures, functions and
  triggers
- These programs are compiled and stored within the database server
- They can also be called by queries

Client side
~~~~~~~~~~~~

- Languages allow programs to integrate querying of the database with
  a procedural language
- Coding in a host language with db hooks (C, C++, Java, Python, etc.)
  using the data structures of these languages
- Coding in frameworks with their own data models (Java, Python, etc)
  with similar db hooks as in above.

Programming with SQL
-----------------------

- All programming paradigms support:

  - Methods to execute queries and update statements

    Executing any SQL statement and catching the outcome 

  - Interpret errors returned if any 

  - Input values from variables into queries, output query results
    into variables
  - Loop over query results (for queries returning multiple tuples)
  - Raise exceptions (which results in rollback of transactions)
  - Store and reuse queries in the shape of cursors
  - Starting and committing transactions

- Client side programs also support:
  
  - Opening/closing connections, allocating/releasing database
    resources for queries

- The actual syntax of the methods for doing this vary, but the
  principle is the same.

Server side language examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Generally database specific

- Postgresql:

  - pl/pgsql: generic procedural language for postgresql
  - pl/pyhton: procedural language that is an extension of python
    (also see pl/tcl, pl/perl)
  
Client side language examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Database specific extensions of host languages, for example

  - libpq: C library for postgresql, uses library calls for specific
    to postgresql
  - OCCI: Oracle library for C

  Write code in C with hooks to the database in the form of
  functions and libraries, and compile using C compiler
  
  - ECPG: embedded programming in SQL, based on the embedded
    programming standard with a postgresql specific pre-compiler, an
    the standard C compiler

- Standard libraries for connecting to the database

  - JDBC is a Java standard library, all databases implement the same
    functions (some non-standard data types will be different)

    To compile code with JDBC functions, the specific adapter
    (library) for a database must be used.

  - No specific standard for libraries based on C, but ODBC is a
    non-language specific standard, .NET tries to achieve the same

  - Python DB-API is a database independent framework for Python
    
    Similar to Java, a module for each database management system is
    needed. The postgresql module is called psycopg2.

Frameworks
-----------

- Frameworks are based on specific design principles for developing
  database backed applications
- Examples:

  - Object-relational-mapping used by Rails, Hibernate, Django,
    WebObjects, .NET (different frameworks have different models)

  - Note that the frameworks can be built on top of other languages
    (such as Java + JDBC)

pl/pgsql
----------

- Note that languages may be different, but the way that communicate
  with SQL is very similar.
- We will go into detail of one language and then show similar
  concepts in other paradigms.

  See full documentation here:

  http://www.postgresql.org/docs/9.5/interactive/plpgsql.html

- pl/pgsql supports the same data types as the database

- Programs and functions can be compiled and used directly at the db
  server

- Main pl/pgsql block has the form:

  ::
     
     [ <<label>> ]
     [DECLARE
     variable declarations ]
     BEGIN
     statement
     END [ label ] ;

-  Variable types:

   ::

      integer
      numeric(5)
      varchar
      tablename%ROWTYPE
      tablename.columname%TYPE
      RECORD

   ROWTYPE and RECORD have subfields, i.e. x.name.

Programming constructs
~~~~~~~~~~~~~~~~~~~~~~~

- Conditionals:

  ::

     IF ... THEN ... ELSIF ... THEN ... ELSE ... END IF 
     Loops:
     [ <<label>> ]
     LOOP
     statements
     END LOOP [ label ];
     
- Returning a value:

  - pl/pgsql does not allow you to modify input variables
    
  - RETURN will return a value
    
  - You can also return a table of rows:
    
    - Return each tuple with RETURN NEXT and finish with RETURN

  ::

     
     CREATE FUNCTION sales_tax(subtotal real, state varchar) RETURNS real AS $$
     DECLARE
        adjusted_subtotal real ;
     BEGIN
        IF state = 'NY' THEN
            adjusted_subtotal = subtotal * 0.08 ;
        ELSIF state = 'AL' THEN
            adjusted_subtotal = subtotal ;
        ELSE
            adjusted_subtotal = subtotal * 0.06;
        END IF ;
        RETURN adjusted_subtotal ;
     END ;
     $$ LANGUAGE plpgsql ;

- Now, test it:

  ::

     select sales_tax(100, 'NY') ;
     
     sales_tax 
     -----------
     8
     (1 row)

- Note: The whole body of the function is entered within the two $$ signs.

Handling SQL:
~~~~~~~~~~~~~~~~

- We will consider three types of SQL expressions:

  #. Statements that return no output but a status (successful or not,
     and what was wrong)
  #. Statements that return a single tuple
  #. Statements that return multiple tuples 

  ::
     
     CREATE FUNCTION sales_tax(subtotal real) RETURNS boolean AS $$
     DECLARE
        adjusted_subtotal real ;
     BEGIN
        adjusted_subtotal = subtotal * 0.06;
        BEGIN
            INSERT INTO temp VALUES (adjusted_subtotal) ;
            RETURN true ;
        EXCEPTION WHEN unique_violation THEN
            RETURN false ;
        END ;
     END ;
     $$ LANGUAGE plpgsql ;

- Now, when you run this function, a row is inserted into table temp.

Executing queries
~~~~~~~~~~~~~~~~~~

- When the query returns a single row, then we can read it directly
  into a variable.
  
- Note that when using variables as input/output, pl/pgsql does not
  need any special delimiters (be careful naming the variables so as
  not to clash with column names)
   
- Example:
  ::
     
     SELECT * INTO myrec FROM emp WHERE empname = myname;
     IF NOT FOUND THEN
     RAISE EXCEPTION 'employee % not found', myname;
     END IF;

   - input: myname, output: myrec

Executing queries
~~~~~~~~~~~~~~~~~~~~~
- When the query returns multiple rows, then a loop is needed to go
  through them one by one.

  - A query returns a stream of tuples, which needs to be processed.

  - Equally important is closing the stream associated with a query
    if required by the programming language.

- Example:

  ::

     [ <<label>> ]
     FOR target IN query LOOP
     statements
     END LOOP [ label ];

     DECLARE
     myRow  RECORD ;
     lastX      INT ;
     yCnt       INT ;
     BEGIN
        lastX = 0 ;
        yCnt = 0 ;
        FOR myRow IN
               SELECT x,y, count(*) as num
               FROM temp GROUP BY x,y ORDER BY x, num ASC LOOP
           yCnt = yCnt + 1;
           IF yCnt < 4 AND lastX = myRow.x THEN
               INSERT INTO temp2 VALUES(myRow.x, myRow.y, myRow.num) ;
           ELSIF lastX <> myRow.x THEN
               lastX = myRow.x ;
               yCnt = 1 ;
               INSERT INTO temp2 VALUES(myRow.x, myRow.y, myRow.num) ;
           END IF ;
        END LOOP ;
     RETURN 1 ;
     END ;

- Note that procedure proc2() computes and inserts the top 3 y values
  (by count) for each x.  Call it as:

  ::

     SELECT proc2() ;

Cursors
~~~~~~~~

- A cursor is a query with a handle. Cursors may have input.
- Cursors may be defined once, and used many times to read tuples.

  A query in a cursor is optimized once, reducing the cost of
  optimizing the query many times.
  
- Functions may return reference to a cursor, allowing a program to
  read tuples that are returned.
- Cursors provide a more efficient implementation of queries returning
  many tuples.

- First, declare cursors:

  ::

     DECLARE curs2 CURSOR FOR SELECT * FROM tenk1;

- Then, execute the associated query by opening them:

  ::

     OPEN curs2;

- Then, retrieve tuples in the result using fetch:

  ::
     
     FETCH curs2 INTO foo, bar, baz;

or

  ::
     
     FOR recordvar IN curs2 LOOP

-  When finished, close the cursor to release allocated memory:

   ::

      CLOSE curs2;
  
- Cursors can also be used for update/delete if it is pointing to a
  specific tuple (similar to the notion of an updatable view).
  - Update/delete the tuple the cursor is pointing to.

Exceptions
~~~~~~~~~~~~

- When an SQL statement is executed, if it is not successful, it raises an error. This error can be caught in the usual try/catch format:

  ::
     
     BEGIN
     statement
     EXCEPTION WHEN condition THEN
       statement
     END ;

- The exception conditions define integrity violations, statement
  errors, connection errors, etc.

- The pl/pgsql statements can also raise exceptions to be caught by
  the calling statement:

  ::
     
     RAISE NOTICE  ''
     RAISE EXCEPTION ''

- Also uncaught exceptions within the function will be raised when the
  function fails.

  
Other languages and formalisms for procedural programming
----------------------------------------------------------

- Given our introduction to programming with pl/pgsql, we will now
  cover some alternate languages to program in databases.

- Each will have constructs similar to pl/pgsql, some will be generic
  and some will be database specific. I invite you to compare them to
  each other and notice similarities.

  
Client-side programming
-----------------------

- Client-side programming languages have additional constructs to
  connect to a database, keep a pool of open connections and close
  connections.

Running and Debugging
~~~~~~~~~~~~~~~~~~~~~~

- Depending on how tight the integration with the database, error
  checking becomes an issue.

- Two sources of syntax errors:

  - Host language syntax errors

  - SQL syntax errors: note that often these are not checked until you
    send the query to the server. So, it is difficult to debug.

- Some client-side programming paradigms are a hybrid of host language
  and additional constructs.

  - Example: Embedded SQL is an SQL standard for writing programs in a
    host language.

  - There is a precompilation phase for only the SQL code and
    variables with better error checking.

  - SQL calls are changed to calls in the host language after
    precompilation.

  - Though writing programs in this paradigm can be a bit awkward and
    it is a less popular platform as a result.

    
Performance
~~~~~~~~~~~~

- One must be especially careful about sending large data sets over
  the network when writing client code.

- When writing client-side code, you must balance the work that must
  be done in the server side and client side.

  - Very complex queries slow down performance.
  - Very simple queries lead to very large data sets being sent over
    the network.

Call level interfaces for client-side programming
--------------------------------------------------

- Supplies the constructs for opening connections, running queries,
  looping over them etc.
- SQL is completely handled with special function calls in the host
  language
- JDBC is an industry standard for Java, supported by all databases
  using drivers.
- Other database specific examples: OCCI for C in Oracle, Libpq for C
  in Postgresql

OCCI Example
--------------

- OCCI is a C-library specific to Oracle, but it is designed to
  very closely resemble JDBC for Java which is a standard.

  ::
     
     #include <occi.h>
     using namespace oracle::occi;

     Environment* const env = Environment::createEnvironment(Environment::DEFAULT);

     Connection* const con = env->createConnection(user, pass, osid);

     Statement* const s = 
            con->createStatement("SELECT a.stageName"
                                 " FROM movies.actors a"
                                 " WHERE a.stagename like 'A%'");

Initialization
~~~~~~~~~~~~~~~~~~~~

- Each OCCI program must initialize an environment at the start of a
  program.

  ::
     
     static Environment* Environment::createEnvironment (Environment::DEFAULT)
     
- The Environment object contains the memory allocator and
  thread-library configuration for OCI.
- You should explicitly terminate an environment at the end of a
  program to release all memory.

  ::

     Environment::terminateEnvironment(env);
     
Connection
~~~~~~~~~~~~~~

- After initialization, you must open a connection to the specific database instance you are going to query. 

  ::

     Connection* Environment::createConnection (string username, string password, string sid)
     
- It will authenticate the given user and password for the given instance id.

  ::

     Connection* con = env->createConnection("scott",  "tiger", "ora9i");
     
- A single connection can be used to query the same database multiple
  times in parallel or sequentially.
  
- You should terminate your connection at the end of your program to
  release all memory at the client and the database server.

  ::

     env->terminateConnection(con);

     
Querying
~~~~~~~~~~

- Once you have established a connection to the database, you are
  ready to execute queries and updates.

- To execute a query, you will need to:

  - Create an SQL statement and load it into a ``statement`` type object.
  - Execute your query which will return one or more tuples. 
  - Create a ``resultset`` object that will allow you to iterate through
    the tuples returned by the query.
  - Close your resultset object so that the database and your program
    releases the necessary memory.
  - Close your statement if you will no longer use it. Note that you
    can use a single statement object repeatedly with different SQL
    queries.

Statements
~~~~~~~~~~~~~~

- Create a statement for a specific connection:

  ::

     Statement* sel_all_stmt
     con->createStatement("SELECT attr1 FROM my_table");

     ..statements to execute this query here…

- Change the query for this statement if necessary:

  ::

     sel_all_stmt->setSQL("SELECT attr2, attr3 FROM new_table");

- When finished, release the statement object.

  ::

     con->terminateStatement(sel_all_stmt);

     
Parametrized Statements
~~~~~~~~~~~~~~~~~~~~~~~~~

- Very often statements are executed multiple times with different
  values.
- For example, suppose a query that finds the name of a specific
  employee may be executed multiple times for different employees.

  ::

     Statement* sel_name con->createStatement("SELECT name FROM employee WHERE id = :1");
     
- This means this query will need to be supplied by one value before it is executed.

  ::

     sel_name->setInt(1, 112223333);
     
- The type used in the “set” method should set the type of the value
  being supplied.
- This type of a query is UNPREPARED if the required value is not
  supplied by the program.
- A prepared statement is optimized once and the query plan is used
  multiple times for each execution of the query saving execution
  time.
  

  ::

     Statement* sel_name con->createStatement("SELECT name FROM employee WHERE id = :1 AND Office = :2");
     sel_name->setInt(1, 112223333);
     sel_name->setString(2, “AE125”);

- Or

   ::

      Statement* sel_name con->createStatement("SELECT name FROM employee WHERE id = :1 AND Office = :2");
      sel_name->setInt(1, ssnVar);
      sel_name->setString(2, officeVar);

- Where ssnVar and officeVar are program variables of types integer
  and string respectively containing the necessary values.
  
Update statements
~~~~~~~~~~~~~~~~~~~~

- All statements that change the database are executed using
  executeUpdate method.
- Examples are insert, update, delete, create …, drop … statements

  ::

     stmt->executeUpdate(“CREATE TABLE basket_tab (fruit VARCHAR2(30), quantity NUMBER)”); 

     statement* s1 = 
     con->createStatement("INSERT INTO my_table (a, b) VALUES (1, 'A')");
     s1->executeUpdate();
     
- Update statements return the total number of tuples effected which
  can be returned by getUpdateCount() method.
  
Select statements
~~~~~~~~~~~~~~~~~~~

- A SELECT query returns one or more tuples by the execution of the
  executeQuery method.
- To process these tuples, you need a result set object which
  processes tuples in a similar way to a file.
- You need to open, iterate through and close a result set to access the tuples.

  ::

     statement* s1 = 
     con->createStatement("SELECT name FROM emp WHERE id < 1000");
     ResultSet r = s1->executeQuery();
     
- Query is executed, the tuples are returned to the program and the
  result set is initialized to the before the first item in the
  results.
- To find the first item, you need to execute "next" operation.
  
- next returns false if the last tuple is already been read.
  
  ::

     statement* s1 = con->createStatement(
              "SELECT id, name FROM emp WHERE id < 1000");
     ResultSet r = s1->executeQuery();
     while (r->next()) {
         varId = r->getInt(1) ;
         varName = r->getString(2) ;
     }
     s->closeResultSet(r);
     
- To read the columns of the current tuple pointed to by the result
  set, get methods are used.
- The type of these methods much match the type of the column returned
  by the program.
  - getXXX(i)  means attribute i of the query should have type XXX.
    
Errors and Status
~~~~~~~~~~~~~~~~~~
- An SQLException is raised for many things that may go wrong for your program:
  - Connection cannot be established
  - The query cannot be executed, etc.
- The exceptions can be caught and checked in the program.

  ::
     
     try{  
        ... operations which throw SQLException ...
     }
     catch (SQLException e){  
        cerr << e.what();
     }

- Other useful methods: ``e.getMessage()``, ``e.getErrorCode()``
  
Errors and Status
~~~~~~~~~~~~~~~~~~~
- As statements are created dynamically and executed in the program,
  it may be necessary to check their status while the program is
  running.
  
- This is accomplished with the status methods for each class.
  
- Examples:
  
  - Check whether the statement is ``UNPREPARED, PREPARED,
    RESULT_SET_AVAILABLE, or UPDATE_COUNT_AVAILABLE``.
    
  - Check whether the result set is ``END_OF_FETCH = 0``,
    ``DATA_AVAILABLE``.
    
- Other methods exist to check for other status related
  information. For example, check whether the result set is empty
  (``r->isNull``).
  
Dynamic Conditions
~~~~~~~~~~~~~~~~~~~

- Suppose tableName is a program variable set to a specific constant by the user.

  ::

     sqlString = "SELECT * FROM " << tableName ;
     statement* s1 = con->createStatement(sqlString);
     ResultSet r = s1->executeQuery();
     while (r->next()) {
		// what attributes are in this result set?
     }
     s->closeResultSet(r);

- The function:
  
  ::

     vector<MetaData> getColumnListMetaData() const; 

  that returns number, types and properties of aResultSet’s columns.
  
Transactions
~~~~~~~~~~~~~
- A transaction starts with the first executeQuery, executeUpdate
  statement and ends until the first commit, abort and rollback
  statement executed for the given connection.

  ::

     con->commit();
     con->rollback();
     
- After a rollback/commit, the next query/update will start a new transaction. 


JDBC
-------

- OCCI is an Oracle specific language for enabling communications
  between a C++ program and a database.
  
- JDBC is a standard for any database product and a Java program for
  the same purpose.
  
- JDBC and OCCI are very similar to each other and have almost
  identical set of classes and methods. In fact, OCCI is based on
  JDBC.
  
- To accomplish the communication between a Java program and a
  database, a set of libraries called a "driver" is needed.
  
- JDBC drivers are specific to the database server.

- Example program:

  ::

     import java.sql.*;
     import oracle.sql.*;
     import oracle.jdbc.driver.*;
     class Employee
     {
     public static void main (String args []) throws SQLException
     {//Set your user name and the password
     String userName = "dummy" ;
     String passWord = "dummy" ;

     // Load the Oracle JDBC driver
     DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());

	Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@acadoracle.server.rpi.edu:1521:ora9",userName,passWord);
     // Create a statement which will return a cursor that 
     // will allow you to scroll the result set using both 
     // "next" and "previous" methods
     
     try {  
           Statement stmt = conn.createStatement
		(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
		
	   ResultSet rset = stmt.executeQuery("SELECT name, oid FROM items ");

	   // Iterate through the result and print the item names
	   while (rset.next ()) {
   	       //Get item name, which is the first column
	       System.out.println (rset.getString (1));
	       
	       PreparedStatement pstmt = conn.prepareStatement ("SELECT name FROM owners WHERE oid = ?") ;
			  
	       //Feed the owner id retrieved from rset into pstmt
	       pstmt.setInt(1, rset.getInt (2));
	       ResultSet dset = pstmt.executeQuery() ;
               if (dset.next())
                   System.out.println(dset.getString (1));
           } }
      }
      catch (SQLException) { error-handling-code } }  }

Python DB-API
----------------

- DB-API is a generic db interface for python (like JDBC). 
- psycopg2 is a python adapter that implements DB-API.

  ::

     import psycopg2 as dbapi2

     db = dbapi2.connect (database="python", user="python", password="python")
     cur = db.cursor()
     cur.execute ("INSERT INTO versions VALUES ('2007-10-18', '2.4.4', 'stable')")
     conn.commit ()
     cur.close()
     db.close()

- Example 2:     

  ::
     
     import psycopg2 as dbapi2

     db = dbapi2.connect (database="python", user="python", password="python")
     cur = db.cursor()

     cur.execute ("SELECT * FROM versions");
     rows = cur.fetchall()
     for i, row in enumerate(rows):
         print "Row", i, "value = ", row

     try:
         cur.execute ("""UPDATE versions SET status='stable' where version='2.6.0' """)
	 cur.execute ("""UPDATE versions SET status='old' where version='2.4.4' """)
	 db.commit()
     except Exception, e:
         db.rollback()
      

libpq: Postgresql C-language interface
---------------------------------------

- The C-language interface for Postgresql uses a number of
  function calls to commmunicate with the database.

- Example:

  ::

     #include <stdio.h>
     #include <stdlib.h>
     #include "libpq-fe.h”
     static void
     exit_nicely(PGconn *conn)
     {
         PQfinish(conn);
         exit(1);
     }

     int
     main(int argc, char **argv)
     {
         const char *conninfo;
	 PGconn     *conn;  PGresult   *res;
	 int         nFields;
	 int         i,  j;
	 
	 conninfo = "port=5432 dbname='sibel' host='localhost' user='sibel' ";
	 conn = PQconnectdb(conninfo);
	 if (PQstatus(conn) != CONNECTION_OK)    {
    	     fprintf(stderr, "Connection to database failed: %s",
             PQerrorMessage(conn));
	     exit_nicely(conn);
	 }

	 /* Start a transaction block */
	 res = PQexec(conn, "BEGIN");

	 if (PQresultStatus(res) != PGRES_COMMAND_OK)
	 {
   	      fprintf(stderr, "BEGIN command failed: %s", PQerrorMessage(conn));
	      PQclear(res);
	      exit_nicely(conn);
	 }
	 /* Should PQclear PGresult whenever it is no longer needed to avoid\
	 memory leaks */
	 PQclear(res);
 
	 res = PQexec(conn, "DECLARE myportal CURSOR FOR select * from pg_database");
	 if (PQresultStatus(res) != PGRES_COMMAND_OK)
	 {
	     fprintf(stderr, "DECLARE CURSOR failed: %s", PQerrorMessage(conn));
	     PQclear(res);
	     exit_nicely(conn);
	 }

	 res = PQexec(conn, "FETCH ALL in myportal");
	 if (PQresultStatus(res) != PGRES_TUPLES_OK)
	 {
	     fprintf(stderr, "FETCH ALL failed: %s", PQerrorMessage(conn));
	     PQclear(res);
	     exit_nicely(conn);
	 }
	 /* first, print out the attribute names */
	 nFields = PQnfields(res);
	 for (i = 0; i < nFields; i++)
  	     printf("%-15s", PQfname(res, i));
	 printf("\n\n");
	 /* next, print out the rows */
	 for (i = 0; i < PQntuples(res); i++)
	 {
  	     for (j = 0; j < nFields; j++)
                 printf("%-15s", PQgetvalue(res, i, j));
	     printf("\n");
         } 

	 PQclear(res);

	 /* close the portal ... we don't bother to check for errors ... */
	 res = PQexec(conn, "CLOSE myportal");
	 PQclear(res);

	 /* end the transaction */
	 res = PQexec(conn, "END");
	 PQclear(res);

	 /* close the connection to the database and cleanup */
	 PQfinish(conn);

	 return 0;
     }
