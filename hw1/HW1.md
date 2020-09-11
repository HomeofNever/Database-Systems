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
T2 = project_{sitename} ((select_{resourcetype = 'hw'} (Resources)) * T1)
Result = project_{username, bestbrowser} (Sites * T2)
```

### Question e

```
Result = (project_{sitename} (Classmeetings)) union (project_{sitename} (Exams)) union (project_{sitename} (Officehours)) union (project_{sitename} (Resources))
```

### Question f

```

```

### Question g

```
T1 = Classes * Teaches

```

### Question h

```
T1 = (select_{dayofweek <> 'Monday' and dayofweek <> 'Wednesday'} (Officehours))
T2 = project_{classcode} (select_{semester = 'Fall', year = '2000'} (Clesses))
T3 = project_{classcode, starttime, duration} (T1 * T2)
ResultCourseCode = project_{}
```

## Question 2

### Question 1

#### Keys

```
ABC
```

#### BCNF

Not satisfied, because

- `AC -> DE` is not trival and `AC` is not a superkey
- `BD -> F` is not trival and `BD` is not a superkey

#### 3NF

Not satisfied, because

- `AC -> DE` is not trival, `AC` is not a superkey, and `DE` are not prime attributes
- `BD -> F` is not trival, `BD` is not a superkey, and `F` is not prime attribute

### Question 2

#### keys

```
ABC, BCD
```

#### BCNF

Satisfied, because

- `ABC -> DEF` is not trival and `ABC` is a superkey
- `AB -> A` is trival
- `BCD -> AEF` is not trival and `BCD` is a superkey

#### 3NF

Satisfied, because BCNF is satisfied

### Question 3

#### keys

```
BC
```

#### BCNF

Satisfied, because

- `ABC -> DE` is not trival and `ABC` is a superkey
- `BC -> AF` is not trival and `BC` is a superkey

#### 3NF

Satisfied, because BCNF is satisfied

### Question 4

#### keys

```
ABC, BDC
```

#### BCNF

Satisfied, because

- `ABC -> DEF` is not trival and `ABC` is a superkey
- `BD -> A` is not trival and `BD` is a superkey

#### 3NF

Satisfied, because BCNF is satisfied
