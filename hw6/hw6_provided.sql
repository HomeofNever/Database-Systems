CREATE OR REPLACE FUNCTION
    recommendation(inputseries integer array
               , topk int
	       , w1 float, w2 float, w3 float, w4 float)
    RETURNS varchar AS $$
DECLARE
   values VARCHAR ;
   myrow RECORD ;
BEGIN
   values = 'You entered: ' || E'\n';

   FOR myrow IN SELECT s.title
         FROM unnest(inputseries) as input(seriesid)
	      , series s
         WHERE s.seriesid = input.seriesid 
   LOOP
       values = values || myrow.title || E'\n'; 
   END LOOP ;
   
   RETURN values ;
END ;
$$ LANGUAGE plpgsql ;
