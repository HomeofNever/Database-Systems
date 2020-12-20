
CSCI 4380 Database Server
=========================

Welcome to the class database server hosted on Microsoft Azure Cloud
services. The server is accessible from a phpPgAdmin interface and can
be accessed at:

   http://csci4380rpi.cloudapp.net/phppgadmin

.. seealso::

   http://www.postgresql.org/docs/9.3/interactive/index.html
   The PostgreSQL documentation.

   http://phppgadmin.sourceforge.net/doku.php
   The PhpPgAdmin web site.
   

Database concepts
------------------

You will be using PostgreSQL 9.3 database with the phpPgAdmin
interface. The server installation you will be using is called
PostgreSQL as well, that is the name of the machine.

PhpPgAdmin is written in PHP and supports SQL as well as web based
interfaces to the database. You are welcome to use whatever works for
you, but I will only concentrate on the SQL interface.

PostgreSQL introduces a number of basic concepts:

- **Server:** the instance of the DBMS running on a specific machine.

- **User or role:** an account on the server usually given by a username
  and password. Some roles may not be able to login to the server, but
  users always can.

- **Database:** a specific filesystem created at the server. Tables are
  created in a specific database. Generally a user or role can access
  any number of databases as long as they possess the specific access
  privileges.

- **Schema:** a namespace that is created within the database. Table names
  are assumed to be unique within the schema. All servers generally
  have a schema called Public which is the default schema. If the
  schema is Public, schema name does not need to be provided in the
  queries. 


The current setup
--------------------    

All the students are given a username and a password. Later in the
semester, we will also give each student a database.  Everybody is assumed
to use the public schema. You can change your own password by using
the following command at the SQL prompt::

   ALTER USER username PASSWORD 'password' ;

Once you change the password, you should logout and log back in to
have full access to the system.

We will create a number of public databases for querying and homeworks
throughout the semester. All students should be able to query tables
in these databases, but not create their own tables. We will create
your own database for this purpose later in the semester. Tables in
your own database should be visible on to you unless you explicitly
give access to specific users.


Working with the server
------------------------

The main mode of working with the class db server is through the SQL
interface. To access this do the following.

- First login to the server by clicking::

    SERVERS -> PostgreSQL

  menu item on the left side menu, and entering your username and password.

- Next, choose a database to work with either from the left side menu
  or the list in the main screen. By default this will be your own
  database or the class database is there is one.

- Finally, choose SQL tab from the top right menu. You can enter SQL
  directly here or enter commands in a file and upload it
  here.

  Remember, regardless of how you input your commands, ALL SQL
  COMMANDS MUST END WITH A ;.

- You can also view various objects in your database using the
  interface provided by phppgadmin. You can list your tables, views,
  functions, etc. by navigating from the left side menu.

- Also, click on Servers -> PostgreSQL, and then choose tab Account
  from top. You can see your account and change password.
