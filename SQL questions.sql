SELECT show_type, 
  COUNT(*) as total_content -- 1
  FROM netflix_titles23
  GROUP BY show_type
  

  SELECT show_type,         -- 2
         rating
  FROM
  (
  SELECT show_type,
       rating,
       COUNT(*),
       RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*)DESC) AS ranking
  FROM netflix_titles23
  GROUP BY 1,2
) as t1
WHERE ranking=1;


SELECT * FROM netflix_titles23  -- 3
WHERE show_type = 'Movie'AND 
release_year = 2020;


SELECT country, COUNT(*) as total_content   -- 4
FROM netflix_titles23
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC 
LIMIT 5;


SELECT *                                                      -- 5
FROM netflix_titles23
WHERE show_type = 'Movie'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) = (
    SELECT MAX(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) 
    FROM netflix_titles23 
    WHERE show_type = 'Movie'
);


SELECT * FROM netflix_titles23 
WHERE STR_TO_DATE(date_added, '%d-%b-%y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR); -- 6 


SELECT * FROM netflix_titles23
WHERE director LIKE '%Rajiv Chilaka%'; -- 7

SELECT * 
FROM netflix_titles23 
WHERE show_type = 'TV Show'
AND duration LIKE '%Seasons%'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;  -- 8



SELECT genre, COUNT(*) AS total_content             -- 9
FROM (
    SELECT TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre FROM netflix_titles23
    UNION ALL
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) FROM netflix_titles23 WHERE listed_in LIKE '%,%'
    UNION ALL
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 3), ',', -1)) FROM netflix_titles23 WHERE listed_in LIKE '%,%,%'
) AS genre_list
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_content DESC;




SELECT                                                                  -- 10
    EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%d-%b-%y')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM netflix_titles23 WHERE country = 'Japan') * 100, 
        2
    ) AS avg_content_per_year
FROM netflix_titles23
WHERE country = 'Japan'
GROUP BY year
ORDER BY year DESC;


SELECT *                                         -- 11
FROM netflix_titles23
WHERE listed_in LIKE '%documentaries%';
  
SELECT *
FROM netflix_titles23                             -- 12
WHERE director IS NULL OR director ='';
 
SElECT * 
FROM netflix_titles23                             -- 13
WHERE casts LIKE '%Salman Khan%' AND 
release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10

SELECT 
show_id,
casts
FROM netflix_titles23


WITH RECURSIVE actor_split AS (                   -- 14
        SELECT show_id, country,
           TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor,
           TRIM(SUBSTRING_INDEX(casts, ',', -1)) AS remaining_casts
    FROM netflix_titles23

    UNION ALL

        SELECT show_id, country,
           TRIM(SUBSTRING_INDEX(remaining_casts, ',', 1)) AS actor,
           TRIM(SUBSTRING_INDEX(remaining_casts, ',', -1))
    FROM actor_split
    WHERE remaining_casts LIKE '%,%'
)

SELECT actor, COUNT(*) AS total_content
FROM actor_split
WHERE actor IS NOT NULL AND actor <> '' 
AND country LIKE '%India%'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;

SELECT 
    EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%d-%b-%y')) AS year,       -- 15
    EXTRACT(MONTH FROM STR_TO_DATE(date_added, '%d-%b-%y')) AS month,
    show_type,
    COUNT(*) AS content_count
FROM netflix_titles23
WHERE date_added IS NOT NULL
GROUP BY year, month, show_type
ORDER BY year DESC, month DESC;






