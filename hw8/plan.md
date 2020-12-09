# Q1

## HW4 Query 1

### Query 

```sql
SELECT
   s.title
   , sd.director
FROM
   series s
   , seriesdirectors sd
WHERE
   s.seriesid = sd.seriesid
   and s.imdbrating <= 5
   and s.seasons >= 15
ORDER BY
   title
   , director
;
```

### Index Creation

```sql
CREATE INDEX serieshw4q1
ON series (imdbrating, seasons, seriesid); 
```

### Origin Plan

```
Sort  (cost=287.37..287.38 rows=1 width=30)
  Sort Key: s.title, sd.director
  ->  Hash Join  (cost=3.92..287.36 rows=1 width=30)
        Hash Cond: (s.seriesid = sd.seriesid)
        ->  Seq Scan on series s  (cost=0.00..283.39 rows=3 width=21)
              Filter: ((imdbrating <= '5'::double precision) AND (seasons >= 15))
        ->  Hash  (cost=2.30..2.30 rows=130 width=17)
              ->  Seq Scan on seriesdirectors sd  (cost=0.00..2.30 rows=130 width=17)
```

### Full Plan After Index Creation

```
Sort  (cost=19.42..19.43 rows=1 width=30)
  Sort Key: s.title, sd.director
  ->  Hash Join  (cost=16.77..19.41 rows=1 width=30)
        Hash Cond: (sd.seriesid = s.seriesid)
        ->  Seq Scan on seriesdirectors sd  (cost=0.00..2.30 rows=130 width=17)
        ->  Hash  (cost=16.74..16.74 rows=3 width=21)
              ->  Bitmap Heap Scan on series s  (cost=5.69..16.74 rows=3 width=21)
                    Recheck Cond: ((imdbrating <= '5'::double precision) AND (seasons >= 15))
                    ->  Bitmap Index Scan on serieshw4q1  (cost=0.00..5.69 rows=3 width=0)
                          Index Cond: ((imdbrating <= '5'::double precision) AND (seasons >= 15))
```

### Conclusion

Plan cost reduced a lot by only doing index scan and read for instead of sequence scan for series table.


## HW4 Query 2

### Query
```sql
SELECT
   count(*) as nummovies
FROM
   movies m
WHERE
   m.imdbrating is null
   and m.rottentomatoes is null
   and (m.year is null or m.year>2015);
```

### Index Creation

```sql
CREATE INDEX movieshw4q2
ON movies (imdbrating, rottentomatoes, year); 
```

### Origin Plan

```
Aggregate  (cost=120.68..120.69 rows=1 width=8)
  ->  Seq Scan on movies m  (cost=0.00..120.61 rows=27 width=0)
        Filter: ((imdbrating IS NULL) AND (rottentomatoes IS NULL) AND ((year IS NULL) OR (year > 2015)))
```

### Full Plan After Index Creation

```
Aggregate  (cost=5.52..5.53 rows=1 width=8)
  ->  Index Only Scan using movieshw4q2 on movies m  (cost=0.28..5.45 rows=27 width=0)
        Index Cond: ((imdbrating IS NULL) AND (rottentomatoes IS NULL))
        Filter: ((year IS NULL) OR (year > 2015))
```

### Conclusion

Plan cost reduced significant by only doing index scan instead of sequence scan for movies table.