
SQL - Embedded SQL Programming
===============================

- In this section, we will look at a different paradigm
  for writing programs that incorporate SQL queries.

- The main distinction between this model and others is that the
  program is written in a host language like C, but contains
  constructs that are foreign to the host language.

- One thing you will notice that it requires programmers to work on
  very low level details of communication with the database. 
  
- To be able to compile these programs, we must first precompile using
  a special program, which will rewrite the program code by replacing
  pieces of it.

- Once precompilation is finished, we compile the remaining code.

- Embedded SQL, ESQL is an industry standard language.   

Overview
------------

- Embedded SQL is an SQL standard for writing a program in a host
  language (like C) with SQL statements starting with the string:

  ::

     EXEC SQL 

  and ending with semicolon (;).
  
- In addition, all variables to be used by the program as input/output
  to a query must be declared within a declare section.

- Often type conversion for preliminary data types between the
  programming language and SQL is done by hand.

- Proc in Oracle, ECPG in Postgresql implements the C embeddings for
  SQL.


- Note that the following notes are based on Oracle embedded SQL
  language (slight differences are possible for postgresql)

- Example program:
  

  ::

     #include <stdio.h>
     exec sql include sqlca;

     char user_prompt[] = "Please enter username and password:  ";
     char cid_prompt[] = "Please enter customer ID:  ";

     int main()
     {
         exec sql begin declare section;       /* declare SQL host variables    */
             char cust_id[5];
             char cust_name[14];
             float cust_discnt;                  /* host var for discnt value    */
             char user_name[20];     
         exec sql end declare section;
    
         exec sql whenever sqlerror goto report_error; /* error trap condition     */
         exec sql whenever not found goto notfound; /* not found condition      */
    
         exec sql unix:postgresql://csc4380.cs.rpi.edu/sibel AS myconnection USER :user_name;
         /* ORACLE format: connect  */
    
         while (prompt(cid_prompt, 1, cust_id, 4) >= 0) {  
             exec sql select cname, discnt 
                     into :cust_name, :cust_discnt   /* retrieve cname, discnt   */
                     from customers where cid = :cust_id;
             exec sql commit work;                     /* release read lock on row */
            
             printf("CUSTOMER'S NAME IS  %s AND DISCNT IS  %5.1f\n",
                  cust_name, cust_discnt);            /* NOTE, (:) not used here  */
             continue;                                 
         }
     }	   
     
ESQL
-------
- Each ESQL statement starts with EXEC SQL keyword and ends with a
  semicolon ;
  
- A pre-compiler will scan a program file and only read the statements
  enclosed within EXEC SQL statements and disregard everything else.

- SQLCA is a specific data structure for storing status codes of all SQL operations

  ::

     /* always have this for error handling*/
     exec sql include sqlca ;             

Connections
----------------

- To be able to perform any operations, we must open a connection to the database. 

  ::

     EXEC SQL CONNECT TO target [AS connection-name] [USER user-name];
     
- Many connection can be opened in a program, but generally one
  connection per database is sufficient.
  
- Different databases can be used in a single program.
  
- Close all connections before the program exists:

  ::

     EXEC SQL DISCONNECT [connection];
     
- Change between multiple open connections with:

  ::

     EXEC SQL SET CONNECTION connection-name;
     
Variables in ESQL
------------------

- All variables that will be used in an SQL statement must be declared
  using an ESQL declaration and data type

  ::
     
     EXEC SQL BEGIN DECLARE SECTION ;
     VARCHAR    e_name[30], username[30] ;
     INTEGER     e_ssn, e_dept_id ;
     EXEC SQL END DECLARE SECTION ;
     
- You can use almost any SQL command in ESQL as long as proper input
  to these commands are provided in the form of program variables.
  
Executing SQL commands
-------------------------

- Suppose we want to find the name of an employee given his/her SSN
  (input by the user of the program):
  
  ::

     EXEC SQL select name, dept_id into :e_name, :e_dept_id
     from employee
     where ssn = :e_ssn ;

  - Program variables are preceded by ":", i.e. :e_ssn.

- Read the value of the variable “e_ssn” and execute the SQL statement
    using this value, store the returned values of columns "name" and
    "dept_id" in the program variables "e_name" and "e_dept_id".
    
- Compare the above query with the expression below. What is the difference?

  ::

     EXEC SQL select name, dept_id 
     from employee  where ssn = e_ssn ;

     
Executing SQL commands
-----------------------

- We are able to write:

  ::

     EXEC SQL select name, dept_id into :e_name, :e_dept_id
              from employee
              where ssn = :e_ssn ;

- Since this query returns a single tuple. For this tuple, we read the
  returned values.

- We will see how to handle queries that return multiple tuples in a minute.
  
Dealing with Strings
---------------------

- There is a mismatch between the definition of a string in Oracle and in C/C++. 
- In C, the end of a string is identified by the null character
  '\0'. Hence, "Sibel" would be stored as characters
  'S','i','b','e','l','\0'.
  
- In Oracle, the length of a string is stored together with the string
  and there is no special end of string character.
  
- If you convert a data string from Oracle to C, you must pad it with
  '\0' manually!
  
- The data type VARCHAR e_name[30] is translated by the pre-compiler
  to the following structure:
  
  ::
     
     struct {
         unsigned short len
         unsigned char arr[30]
     } e_name ;

- Putting the pieces together:

  ::

     strcpy(username.arr, “Sibel Adali") ;
     username.len = strlen(“Sibel Adali") ;
     strcpy(passwd.arr, “tweety-bird") ;
     passwd.len = strlen(“tweety-bird") ;
     exec sql 	connect :username  identified by :passwd ;
     scanf(“%d", &e_ssn) ;
     exec sql 	select name, dept_id into :e_name, :e_dept_id
                from employee where ssn = :e_ssn ;
     e_name.arr[e_name.len] = '\0' ;   /* so can use string in C*/
     printf(“%s", e_name.arr) ;
     exec sql commit work ;  /* make any changes permanent */
     exec sql disconnect ;     /* disconnect from the database */
     
Status Processing
--------------------

- SQL Communications area is a data structure that contains information about

  - Error codes (might be more detailed than SQLSTATE)
  - Warning flags 
  - Event information 
  - Rows-processed count 
  - Diagnostics for all processed SQL statements.
    
- Included in the program using

  ::

     EXEC SQL INCLUDE SQLCA; or #include <sqlca.h>
     
- It is possible to get the full text of error messages and other
  detailed status information.
  
- Whenever an SQL statement is executed, its status is returned in a
  variable named ``"SQLSTATE"``
  
- This variable must be defined in the variable section, but it is
  populated with values automatically

  ::

     EXEC SQL BEGIN DECLARE SECTION;
       char    SQLSTATE[6] ;
     EXEC SQL END DECLARE SECTION;
     
- Different errors and conditions have values that might be vendor specific.
  
Status processing
-------------------

- ``sqlca`` covers both warnings and errors. If multiple warnings or
  errors occur during the execution of a statement, then sqlca will
  only contain information about the last one.
  
- If no error occurred in the last SQL statement, sqlca.sqlcode will
  be 0 and sqlca.sqlstate will be "00000".
  
- If a warning or error occurred, then sqlca.sqlcode will be negative
  and sqlca.sqlstate will be different from "00000".
   
- If the last SQL statement was successful, then sqlca.sqlerrd[1]
  contains the OID of the processed row, if applicable, and
  sqlca.sqlerrd[2] contains the number of processed or returned rows,
  if applicable to the command.
  
- The code can be checked after each statement and error handling code
  can be written

  - Commit, rollback
  - Exit program, etc.

  ::
     
     if (strcmp(SQLSTATE, "000000") != 0)
          rollback ;
	  
- It is also possible to use trap conditions that remain active
  throughout the program.

  ::
     
     EXEC SQL WHENEVER <condition> <action> ;
     
  - Conditions: ``SQLERROR``, ``SQLWARNING``, ``NOT FOUND``
  - Actions: ``DO function``, ``DO break``, ``GOTO label``,
    ``CONTINUE``, ``STOP``
    
- Because WHENEVER is a declarative statement, its scope is
  positional, not logical. That is, it tests all executable SQL
  statements that physically follow it in the source file, not in the
  flow of program logic.
  
- A WHENEVER directive stays in effect until superseded by another
  WHENEVER directive checking for the same condition.
  
Transactions
-----------------

- Transactions start with the logically start with the first SQL
  statement and end with either a COMMIT or ROLLBACK statement
  
- It is possible to set boundaries of transactions with the SQL statement:

  ::

     BEGIN ;
     SET TRANSACTION READ ONLY
         ISOLATION LEVEL READ COMMITTED
         DIAGNOSTICS SIZE 6 ;
	 
- Diagnostics size is the number of exception conditions that can be
  described at one time in the status.
  
- READ ONLY, READ/WRITE transactions allow the programmer to define
  the type of the transaction
  
- Isolation level allows the programmer to define the desired level of
  consistency
  
ESQL - Cursor Operations
--------------------------
- Declare a cursor using a regular SQL query (no "into").

  ::
       
     EXEC SQL DECLARE emps_dept CURSOR FOR
           select ssn, name from employee
	   where dept_id = :e_dept_id ;

- Open a cursor: means the corresponding SQL query is executed, the
  results are written to a file (or a data structure) and the cursor
  is pointing to the first row.

  ::

     EXEC SQL OPEN emps_dept ;

- Read the current row pointed to by the cursor using "fetch". At the
  end of fetch, the cursor is moved to point to the next tuple.

  ::

     EXEC SQL FETCH emps_dept INTO :e_ssn, :e_name ;

- How do we know when we reach the end of a cursor?

  - Check the "sqlcode" to see if the end of a cursor is reached (its
    expected value depends on the system).

    ::

       if (sqlca.sqlcode == -1) { … }

- Error handling statements

  ::

     EXEC SQL WHENEVER NOT FOUND {}

Cursors and snapshots
-----------------------

- If a cursor is declared as "INSENSITIVE", the contents of the cursor
  is computed once when the cursor is opened, and remains the same
  until the cursor is closed, even if the underlying data tables
  change during the this time.


  ::

     DECLARE cursor-name CURSOR INSENSITIVE CURSOR FOR table-expression

- This type of cursor is a snapshot of the database, a view of it at a
  specific time.


  ::
     
     DECLARE cursor_name [INSENSITIVE][SCROLL] CURSOR FOR
       table_expression
       [ORDER BY order-item-comma-list]
       [ FOR [READ ONLY | UPDATE | OF column-commalist] ]

Cursors for update
--------------------

- If a cursor is declared for update, then updates can be performed on
  the current tuple.

  ::

     DECLARE CURSOR cursor-name CURSOR FOR table-expression
                 FOR UPDATE OF column-list

     UPDATE table-name SET assignment-list 
                WHERE CURRENT OF cursor-name

     DELETE FROM table-name WHERE CURRENT OF cursor-name

- For these updates to have an effect, the cursor must not be
  INSENSITIVE.

Constraints
---------------

- When constraints are violated, they cause an exception (or sqlerror)
  to be thrown.

- When are constraints violated?

  - If constraint checking for a constraint is immediate, as soon as
    an SQL statement causes the constraint to become false, it is
    rolled back.

  - If a constraint is defined to be deferrable, then the constraint
    is not checked until a transaction tries to commit. Then, if it is
    violated, the whole transaction is rolled back.

    ::

       CONSTRAINT name CHECK … DEFERRABLE

       
Dynamic SQL
-------------

- In Dynamic SQL, embedded SQL statements are created on the fly using
  strings!

- these strings are fed to an exec sql statement

  ::

     exec sql execute immediate :sql_string

- Since dynamic SQL statements are not known to the pre-compiler at
  compile/initiation time, they must be optimized at run time!

- Create a query once using a prepare statement and run it multiple
  times using the execute statement.

  ::

     strcopy(sqltext.arr, "delete from employee where ssn = ?") ;
     sqltext.len=str.len(sqltext.arr) ;
     exec sql prepare del_emp from :sqltext ;
     exec sql execute del_emp using :cust_id ;

SQLDA
------------

- When we execute a dynamic SQL statement, we do not know which
  columns will be returned and how many columns will be returned.

- The SQLDA descriptor definition allows us to find the number of
  columns and the value for each column.

  ::
     
     exec sql include sqlda ;
     exec sql declare sel_curs cursor for sel_emps ;
     exec sql prepare sel_emps from :sqltext ;
     exec sql describe sel_emps into sqlda ;
     
     exec sql open sel_curs ;
     exec sql fetch sel_curs using descriptor sqlda ;
  
