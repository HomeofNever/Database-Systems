.. role:: underline
    :class: underline


Introduction to Relational Databases
=====================================

Course Notes
-------------

- These notes are meant as a study guide. They will often be an
  outline of the material discussed in class.

- The notes are meant to complement the book, not replace.


Terminology
------------

- *DBMS (Database Management System)*
  is a software tool for storing and managing large amounts of data.

- *Database*
  is a collection of data organized for a specific
  application, often stored in a DBMS.

- *Database application*
  is a software product that uses DBMSs to
  store one or more databases to accomplish a specific purpose.

What makes something a DBMS?
-----------------------------

- Can we call any tool for storing data a DBMS?

  - Is Excel a DBMS?
  - Is your file system a DBMS?

- What are desired properties of a DBMS?

  - what type of data can be stored (data model)
  - store massive amounts of data 
  - allow access (read/write/update) to stored data easily (query language)
  - allow durable data storage, even when there are power failures (durability)
  - allow multiple users to read and write the same data (concurrent access)


DBMS Components
----------------

A DBMS is a complex software system with many components:

- Storage manager

  - Index/file manager

- Database language tools
  
  - Data query/manipulation language compiler (DML)
  - Data definition language compiler (DDL)

- Query execution engine
  
  - Buffer manager

- Transaction manager
  
  - Logging and recovery
  - Concurrency control

- *A database administrator*
  is responsible for designing the 
  data model. 

- *A database programmer*
  is responsible for writing application
  software that stores the database.

- *A DBMS systems administrator*
  is responsible for installation 
  and tuning of the DBMS system.

A C I D
-------

A program that changes data is called a *transaction*.

A DBMS is *generally* expected to support ACID properties for
transactions that can be implemented on them:

- Atomicity: transactions must either complete fully or leave no
  effect in the database.
- Consistency: DMBS must not allow the programmers to violate the
  consistency rules for the database schema.
- Isolation: multiple transactions executing at the same time should
  result in a database state identical to transactions executing one
  at a time.
- Durability: when a transaction completes, DBMS must guarantee its
  results are recorded and not lost. 

There may be different ways to define these properties in a DBMS as we
will see.


Databases
----------

- *Database*
   is given by rules regarding data (data schema or data model) and
   the data (database instance)

- *Database schema (or data model)* 
  describes what types of data are valid to store

- *Database instance* 
  is the 
  actual data that satisfies the rules of the database schema.

- We often use the term database to refer to the database instance
  assuming the data model is encapsulated within the data

- Relational data model is the most popular way to describe data
  schema, but many others are possible: RDF, graph data,
  object-oriented, object-relational
 
Data Model
----------

- Logical data model

  - Relations and attributes
  - Constraints: what is valid data and what is not

- Physical data model

  - Where to store the data: which file systems, distributed, replicated
  - How to store the data: which indices to create

- Application logic

  - Built on top of database queries: declarative, write once and 
    optimize on top of the logical data model

Relational Data Model
-----------------------

- *Relations (or tables)*
  store information about the world

- *Attribute (or column)* 
  is a property of a specific object represented by a relation

- *Tuple (or row)* is a specific object stored in a relation.

- *Domain* 
  is a set of valid values. 

  - Simple domains are integers, strings.
  - More complex domains can be defined with restrictions over these
    domains: a RIN is an 8 digit integer, starts with 6.

- *Schema* 
  for a relation defined the names of the attributes and the
  domain for the attributes.

- Note: logical vs. physical names are used interchangeably, but
  remember the distinction:

  - Logical terms refer to the mathematical definition of the relational 
    data model: based on set semantics.

  - Physical terms refer to the storage/implementation of the same
    data model. Sometimes the implementation is not identical to the
    logical model. 

  For now, we care about the logical model.


Relational Data Model
-----------------------

- A database is given by a set of relations. 

- Each relation has a name and stores a set of tuples.

- Each relation schema consists of a set of attributes, the ordering
  of the attributes is not relevant.

- Each attribute has a domain, the set of valid values. 

Relation Instance
-----------------

- A relation contains a set of tuples

- In a valid relation instance each tuple contains values 
  for all the attributes in the relation
  schema that are drawn from the domain of that attribute.

- We can represent a relation in one of many ways:

  - A table:

   **Hero**

   ==============  ===============
   Alias           Name
   ==============  ===============
   Flash           Barry Allen
   Arrow           Oliver Queen
   Jessica Jones   Jessica Jones
   ==============  ===============

  - A logical representation of tuples using predicates where
    the attributes are arguments of the predicate. Each tuple is a
    fact about the world.

    ::

     Hero('Flash', 'Barry Allen')
     Hero('Arrow', 'Oliver Queen')
     Hero('Jessica Jones', 'Jessica Jones')


  - A set representation:

    ::

      Hero = { <'Flash':Alias, 'Barry Allen':Name>,
               <'Arrow':Alias, 'Oliver Queen':Name>,
               <'Jessica Jones':Alias, 'Jessica Jones':Name> }

  - All representations are equivalent after we agree on the convention.

Example relation: Avengers
---------------------------

==========================  ============  =======  =======  =========  ========================================================
Name/Alias                  Appearances   Gender   Year     NumYears   URL
==========================  ============  =======  =======  =========  ========================================================
Peter Benjamin Parker       4333          MALE     1990     25         http://marvel.wikia.com/Peter_Parker_(Earth-616)#
Steven Rogers               3458          MALE     1964     51         http://marvel.wikia.com/Steven_Rogers_(Earth-616)
James "Logan" Howlett       3130          MALE     2005     10         http://marvel.wikia.com/James_Howlett_(Earth-616)#
Anthony "Tony" Stark        3068          MALE     1963     52         http://marvel.wikia.com/Anthony_Stark_(Earth-616)
Thor Odinson                2402          MALE     1963     52         http://marvel.wikia.com/Thor_Odinson_(Earth-616)
Reed Richards               2125          MALE     1989     26         http://marvel.wikia.com/Reed_Richards_(Earth-616)#
Robert Bruce Banner         2089          MALE     1963     52         http://marvel.wikia.com/Robert_Bruce_Banner_(Earth-616)
Clinton Francis Barton      1456          MALE     1965     50         http://marvel.wikia.com/Clint_Barton_(Earth-616)
Henry Jonathan "Hank" Pym   1269          MALE     1963     52         http://marvel.wikia.com/Henry_Pym_(Earth-616)
Natalia Alianovna Romanova  1112          FEMALE   1973     42         http://marvel.wikia.com/Natalia_Romanova_(Earth-616)#
Victor Shade (alias)        1036          MALE     1968     47         http://marvel.wikia.com/Vision_(Earth-616)
Carol Susan Jane Danvers    935           FEMALE   1979     36         http://marvel.wikia.com/Carol_Danvers_(Earth-616)#
Jennifer Walters            933           FEMALE   1982     33         http://marvel.wikia.com/Jennifer_Walters_(Earth-616)#
Jessica Miriam Drew         525           FEMALE   2008     7          http://marvel.wikia.com/Jessica_Drew_(Earth-616)#
Roberto da Costa            491           MALE     2013     2          http://marvel.wikia.com/Roberto_da_Costa_(Earth-616)#
Maria Hill                  359           FEMALE   2010     5          http://marvel.wikia.com/Maria_Hill_(Earth-616)#
Jessica Jones               205           FEMALE   2010     5          http://marvel.wikia.com/Jessica_Jones_(Earth-616)#
==========================  ============  =======  =======  =========  ========================================================

Rules of Relational Data Model
-------------------------------

- The domain of attributes have to be simple: integer, float, decimal, 
  string, boolean,
  date, time, timestample or restrictions of these (9 digit integer).

  - This restriction is called the first normal form (1NF): attributes are
    indivisible pieces of information.!

  - It says that relations are simple flat pieces of information.


- Each relation contains a set of attributes: the ordering of attributes is not important for the meaning of the relation.

- Each relation instance contains a set of tuples. No two tuples can repeat, because we are making a logical statement:

  - Jessica Jones is an avenger. This does not change even if we repeat this value multiple times.

- All relations have at least one key. 


Key
---

- A key is a set of attributes in a relation such that no two different tuples may have the same value
  for the attributes in the key.

- In different terms: a key is a way to identify a specific tuple. 

- Keys define the meaning of the relation.

- All relations have a key. Some relations may have multiple keys.

- We will discuss some basic relations: student, class, section, book

  Student(rin, name, major, year)   Key: rin

  Movies(title, year, studio, boxofficevalue)  Key: title, year

- We generally underline the key attributes. See below:

  .. math::

     Student(\underline{rin}, name, major, year)
     
     Movies(\underline{title, year}, studio, boxofficevalue)


Defining relations in SQL
-------------------------

- To store a relation, we create a Table in a relational database system.

- Examples of attribute types are following:

  - CHAR(n), VARCHAR(n), BIT(n)
  - BOOLEAN
  - INT
  - FLOAT, DOUBLE   ; floating point precision
  - NUMERIC(n,p)      ; fixed point precision
  - DATE

-  Create table command
   
   ::
      
      CREATE TABLE tablename
      (
          attribute1  datatype
	  , attribute2  datatype

	  , ...

	  , attributen  datatype
	  constraints
      ) ;
      
-  Example

   ::
      
      CREATE TABLE student
      (
        id int
        , name  varchar(255)
        , major  char(4)
        , enrolledDate   date
        , constraint student_pk primary key (id)
	--  student_pk is the name we have given to the primary key constraint
      )
       

SQL for changing tables
------------------------

-  Delete a table (with all the tuples in it):

   ::
      
      DROP TABLE tablename ;
      
-  Add a new attribute to a table:

   ::
      
      ALTER TABLE tableName add attributeName attributeType ;
      
- Remove an attribute from a table:
  
  ::
     
     ALTER TABLE tableName drop attributeName ;
