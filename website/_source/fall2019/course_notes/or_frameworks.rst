
SQL - Object-Relational Frameworks
===================================

- Tight integration between application logic and the database

- Describe the database model as an object-oriented class description

- Write queries not in SQL but directly in the programming language

- Create tools that are DB agnostic  

- Main focus:

  - Most web based db programming requires a number of tasks that are
    highly repetitive and common (and not as glamarous as SQL
    programming).

    Examples: data validation, input sanitization, etc.
    
  - Frameworks are designed to provide common tools for these tasks so
    that the programs are easy and fast to develop.

    Examples: authentication tools, password/email data types

- Many commonly used examples:

  - Django for Python: Disqus, bitbucket, instagram, pinterest
  - Ruby on Rails or Grail for Ruby: airbnb, ask.fm, couchsurfind, github
  - Hibernate for Java
  - DataObjects.Net for .NET
  - SQLAlchemy and Flask for Python

- We will base the examples below on Django.    

MVC/T: Models, Views and Templates (or Controllers)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Build a full-stack application by defining the different components

  - Models are the data models of the tables that will be stored in
    the database

  - Views are the HTML pages that you will see, loading data from
    models and executing functions for certain actions (like button
    clicks)

  - Controller is the application logic: that tells you what will
    happen when certain actions are executed: run queries, db changes
    and render new HTML pages

- Often views are a mix of HTML/Python and Javascript for active
  elements

Models
~~~~~~~~~

- Define your DB tables using an object-relational paradigm

- Each table is a class, storing objects of this type

  ::

     class Student(models.Model):
         name = models.CharField(max_length=255)
         email = models.CharField(max_length=255)
         address = models.CharField(max_length=255)
         year = models.IntegerField()
         gpa = models.FloatField()
         major = models.CharField(max_length=2)
    
- The table associated will be called `Students` and will have a
  primary key `id` by default (can be overridden).


Views
~~~~~~~~~~~~~~~

- Views can query these objects using simple queries:

  ::

     def index(request):
         students = Student.objects.all()
         return render(request, 'index.html', {'students':students,})    

- Templates can render these objects using simple loops:

  ::

     <ul>
       {% for student in students %}
         <li><b>{{ student.name }}</b>:</li>
            <ul>
             <li>ID: {{student.id}}</li>
             <li>Address: {{student.address}}</li>
             <li>Email: {{student.email}}</li>
             <li>Year: {{student.year}}</li>
            <li>GPA: {{student.gpa}}</li>
          </ul>	
       {% endfor %}
     </ul>


Complex Models
~~~~~~~~~~~~~~~~~~~

- Foreign keys:

  ::

     class Department(models.Model):
         name = models.CharField(max_length=255)
         office = models.CharField(max_length=40)
         phone = models.CharField(max_length=12)
	 
     class Major(models.Model):
         name = models.CharField(max_length=255)
         department = models.ForeignKey(Department, on_delete.Models.CASCADE)


- Allows for the querying and retrieval of models through the foreign
  keys:

  ::

     departments = Deparment.objects.all()
     majors = Major.objects.all()
     for major in majors:
         print (major.department.name)

     majors = Major.objects.filter(department__name = 'Computer Science')
     

Querying
~~~~~~~~~

- Most queries are simple filter statements over single relations or
  relations obtained through foreign keys.

- Does not require you to know full SQL.

- Most application function is easily mapped to CRUD operations
  (create, read, update and delete) that are easily supported

- Be careful if your join is different than what the foreign key
  implies

- Be careful about how much data is read for each object and when: for
  deep nested structures, does it read the whole hierarchy?

  
     
Summary
---------

- OR frameworks are quite powerful and provide a lot of functionality
  off the shelf

- DRY principle: do not repeat yourself: write code once and use many
  times

- For the tools, you pay a price: restrictive models and naming
  conventions

  Example: lack of support for multi-attribute keys

- You need to be careful if your query is best handled by the tool and
  by custom SQL

- Same as application logic: is it better to write functions in the
  views or a stored procedure in the back end.
