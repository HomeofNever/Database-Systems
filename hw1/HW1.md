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
T1 = project_{classcode, sitename} Classmeetings
T2 = project_{classcode, sitename} Exams
T3 = project_{classcode, sitename} Officehours
T4 = project_{classcode, sitename} Resources
T5 = T1 union T2 union T3 union T4 union T5
T6(classcode6, sitename6) = T5
T7 = project_{classcode6, classcode} (T6 x T5)
T8 = project_{classcode6, classcode} (select_{classcode6 <> classcode and sitename = sitename6 } (T6 x T5))
Result = T7 - T8
```

### Question g

```
T1 = project_{classcode, classname, instructorname} (Classes * Teaches)
T2(classcode2, classname2, instructorname2) = T1
T3(classcode3) = project_{classcode} (select_{classcode = classcode2 and instructorname <> instructorname2} (T1 x T2))
Result = project_{classcode, classname} (select_{classcode <> classcode3} (Classes x T3))
```

### Question h

```
T1 = (select_{dayofweek <> 'Monday' and dayofweek <> 'Wednesday'} (Officehours))
T2 = project_{classcode} (select_{semester = 'Fall', year = '2000'} (Clesses))
T3 = project_{classcode, starttime, duration} (T1 * T2)
ResultCourseCode = project_{classcode} T3
ResultOfficeHour = T3
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
