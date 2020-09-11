# DBS Hw 1

## Question 1

### Question a

```
T1 = project_{classcode, instructorname, email} (select_{instructorname = 'Fogg'} (Teaches))
T2 = select_{examdate > '11-01-2020'} (Exams)
Result = project_{classname, examname, examdate} (T1 * T2 * Classes)
```

### Question b

```
Result = project_{classcode, dayofweek, starttime} (Classmeetings)) * (project_{classcode, dayofweek, starttime} (Officehours)
```

### Question c

```
Result = project_{classcode, classname} ((select_{dayofweek='Monday'} (Classmeetings)) * Classes)
```

### Question d

```
T1 = project_{classcode} (select_{semester = 'Fall', year = '2000'} (Classes))
T2 = project_{sitename, username} ((select_{resourcetype = 'hw'} (Resources)) * T1)
Result = project_{username, bestbrowser} (Sites * T2)
```

### Question e

```

```
