# Question 1

## Attributes

- `eventname`
- `edate`
- `starttime`
- `duration`
- `URL`
- `description`
- `host`
- `panelistname`
- `panelistemail`
- `participantid`
- `participantname`
- `participantemail`
- `participantaddress`
- `ticketprice`

## Functional Dependencies

- `edate starttime => duration URL description host`
- `participantid => participantname participantemail participantaddress ticketprice`
- `edate starttime panelistname => panelistemail`

## Relation checks

### Keys

```
edate starttime partcipantid panelistname
```

#### BCNF

Not satisfied, because 

-  `edate starttime => duration URL description host` is not trival and `edate starttime` is not a superkey

#### 3NF

Not satisfied, because

- -  `edate starttime => duration URL description host` is not trival, `edate starttime` is not a superkey, and `duration, URL, description, host` are not prime arrtibutes


# Question 2

## Decomposition 

### Projection of functional dependencies

- `R1(A, B, C, F, G)`
  - F1 = `{ AFG -> B,  ABC -> F }`
- `R2(A, B, C, D, E)`
  - F2 = `{ AC -> D, AC -> E }`

### Union 

```
Fp = F1 union F2 = { AFG -> B, ABC -> F, AC -> D, AC -> E }
F = { AC -> D , AC -> E, BE -> F, AFG -> B }
```

### Check

- `AC -> D` is in Fp
- `AC -> E` is in Fp
- `BE -> F` is not in Fp
  - Compute with respect to Fp: `BE+ = { B, E }`, `F` is not compiled 
- `AFG -> B` is in Fp


Fp is not equivalent to F, so this decompostion is not dependency preserving. 


# Question 3

## Table

Note: Changes are bolded

### Initial State

|REL|A|B|C|D|E|F|G|
|--|--|--|--|--|--|--|--|
|R1|a|b|c|d|e1|f1|g1|
|R2|a|b|c|d2|e|f2|g|
|R3|a3|b|c3|d3|e|f|g3|
|R4|a|b4|c4|d4|e|f4|g|

### Apply `AC -> BD`

|REL|A|B|C|D|E|F|G|
|--|--|--|--|--|--|--|--|
|R1|a|b|c|d|e1|f1|g1|
|R2|a|b|c|**d**|e|f2|g|
|R3|a3|b|c3|d3|e|f|g3|
|R4|a|b4|c4|d4|e|f4|g|

### Apply `BC -> E`

|REL|A|B|C|D|E|F|G|
|--|--|--|--|--|--|--|--|
|R1|a|b|c|d|**e**|f1|g1|
|R2|a|b|c|d|e|f2|g|
|R3|a3|b|c3|d3|e|f|g3|
|R4|a|b4|c4|d4|e|f4|g|

### Apply `BE -> DF`

|REL|A|B|C|D|E|F|G|
|--|--|--|--|--|--|--|--|
|R1|a|b|c|d|e|f1|g1|
|R2|a|b|c|d|e|**f**|g|
|R3|a3|b|c3|**d**|e|f|g3|
|R4|a|b4|c4|d4|e|f4|g|

Relation R2 has no subscript, so this decomposition is lossless.

# Question 4

## Section a

### Keys

```
ABGHF
```

### 3NF

Not satisfied, because `AD -> CE` is not trival and `AD` is not superkey 

## Section b

- `R1(A, D, C, E)`
- `R2(B, E, F, G)`
- `R3(A, G, C)`
- `R4(A, B, G, H, F)`

## Section c

### BCNF 

- `R1(A, D, C, E)`
  - F1 = `{ AD -> CE, C -> D }`
  - Key: `AD`
  - Not Satisfied, `C -> D` is not trival and `C` is not a super key
- `R2(B, E, F, G)`
  - F2 = `{ BEF -> G }`
  - Key : `BEF`
  - Satisfied, because `BEF -> G` is not trival and `BEF` is a superkey
- `R3(A, G, C)`
  - F3 = `{ AG -> C }`
  - Key: `AG`
  - Satisfied, because `AG -> C` is not trival and `AG` is a superkey
- `R4(A, B, G, H, F)`
  - F4 = `{}`
  - Key: `ABGHF`
  - Satisfied

# Question 5

## Splitting Rules

- `AC -> B`
- `AC -> D`
- `BC -> B`
- `BC -> E`
- `ABC -> E`

## Remove Trival

- `AC -> B`
- `AC -> D`
- `BC -> E`
- `ABC -> E`

## Removing `X -> Y`

- `AC -> B` 
  - Cannot remove
    - For F', AC+ = `{ A, C, D }`
    - For F, AC+ = `{ A, C, B, D, E }`
    - Not equivalent
- `AC -> D`
  - Cannot remove
    - For F', AC+ = `{ A, C, B, E }`
    - For F, AC+ = `{ A, C, D, B, E }`
    - Not equivalent
- `BC -> E`
  - Cannot remove
    - For F', BC+ = `{ B, C }`
    - For F, BC+ = `{B, C, E}`
    - Not equivalent
- `ABC -> E`
  - Cannot remove
    - For F', ABC+ = `{ A, B, C, D }`
    - For F, ABC+ = `{ A, B, C, D, E }`
    - Not equivalent

## Replace `XZ -> Y` with `X -> Y`

- `AC -> B`
  - Remove `C`, we have `A -> B` for F' 
    - Cannot replace
      - For F', A+ = `{ A, B }`
      - For F, A+ = `{ A }`
      -  Not equivalent
   - Remove `A`, we have `C -> B`
     - Cannot replace
       - For F', C+ = `{ C, B }`
       - For F, C+ = `{ C }`
       - Not rquivalent  
- `AC -> D`
  - Remove `A`, we have `C -> D` for F' 
    - Cannot replace
      - For F', C+ = `{ C, D  }`
      - For F, C+ = `{ C }`
      -  Not equivalent
  - Remove `C`, we have `A -> D` for F' 
    - Cannot replace
      - For F', A+ = `{ A, D }`
      - For F, A+ = `{ A }`
      -  Not equivalent
- `BC -> E`
     - Remove `B`, we have `C -> E` for F' 
       - Cannot replace
        - For F', C+ = `{ C, E }`
        - For F, C+ = `{ C }`
        -  Not equivalent
    - Remove `C`, we have `B -> E` for F' 
      - Cannot replace
        - For F', B+ = `{ B, E }`
        - For F, B+ = `{ B }`
        -  Not equivalent
- `ABC -> E`
    - Remove `A`, we have `BC -> E` for F' 
      - Can replace
        - For F', BC+ = `{ B, C, E }`
        - For F, BC+ = `{ B, C, E }`
        -  Equivalent/Same

So we have: 

- `AC -> B`
- `AC -> D`
- `BC -> E`
- `BC -> E`

## Combining Rule

Minimal Basis:

- `AC -> B`
- `AC -> D`
- `BC -> E`


# Question 6

## Find Violation

### Keys

```
oname mid
```

### Result 

- cname -> df url email 
  - violate
- cname mid -> mname
  - violate
- oname -> oposition
  - violate
- oname -> cname
  - violate

## BCNF

Pick any violation and start decomposition

- `oname -> cname`
  - oname+ = `{ oname, cname, df, url, email , oposition }`
  - `R1(oname, cname, df, url, email, oposition)`
    - F1 = `{cmame -> df url email, oname -> oposition, oname -> cname}`
    - Keys: `oname`
    - `cname -> df url email` violates BCNF
  - `R2(oname, mid, mname)`
    - F2 = `{}`
    - Keys: `oname mid mname`
    - Satisfied BCNF

Decompose on `cname -> df url email`, with `R1(oname, cname, df, url, email, oposition)`

-  `cname -> df url email`
   -  cname+ = `{ cname, df, url, email }`
   -  `R11(cname df url email)`
      -  F11 = `{ cname -> df url email }`
      - Key: `cname`
      - Satisfied BCNF
   - `R12(cname, oname, oposition)`
     - F12 = `{ oname -> oposition, oname -> cname }`
     - Key: `oname`
     - Satisified BCNF

### Result 

- cname df url email
- cname, oname, oposition
- oname, mid, mname