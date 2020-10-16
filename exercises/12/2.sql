SELECT
	id
FROM
	episodes
WHERE
	viewers7day > (SELECT AVG(viewers7day)::NUMERIC(5,2) FROM episodes)
ORDER BY
	id;