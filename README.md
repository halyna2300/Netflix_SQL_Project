# Netflix Movies & TV Shows Data Analysis Project Using SQL

![Netflix SQL Project](https://github.com/halyna2300/Netflix_SQL_Project/raw/main/IMG_8405.jpeg)

## Overview  
This project explores **Netflix's vast library of movies and TV shows** using **SQL for data analysis**. By examining content trends, country distributions, and key performance indicators, this analysis provides insights into **Netflix’s content strategy, user preferences, and overall catalog growth**. The project focuses on extracting meaningful data to identify **patterns in genre popularity, top-producing countries, release trends, and key contributors** such as actors and directors.  

## Objectives
- **Compare the distribution of Movies vs. TV Shows** on Netflix.  
- **Identify the most popular content ratings** and their frequency.  
- **Analyze content availability across different countries.**  
- **Track how Netflix’s catalog has expanded over time** by analyzing release trends.  
- **Discover the longest-running movies and TV shows** on the platform.  
- **Identify top actors and directors contributing to Netflix's library.**  
- **Uncover insights into the most popular genres and themes.**  
- **Analyze patterns in content additions based on monthly and yearly trends.**  

## **Dataset**  
The dataset contains detailed metadata about **movies and TV shows on Netflix**, including:  
- **Title, Type (Movie/TV Show), Director, Cast**  
- **Country, Date Added, Release Year**  
- **Rating, Duration, Genre, and Description**  

🔗 **Dataset Link:** [Netflix Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)  

## **Schema**  
```sql
DROP TABLE IF EXISTS netflix_titles23;
CREATE TABLE netflix_titles23 (
    show_id VARCHAR(10),
    show_type VARCHAR(10),
    title VARCHAR(255),
    director VARCHAR(255),
    cast TEXT,
    country VARCHAR(255),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(20),
    listed_in VARCHAR(255),
    description TEXT
);

##Business Questions & SQL Queries

### **How many Movies vs. TV Shows are available on Netflix?**

```sql
SELECT show_type, COUNT(*) as total_content
FROM netflix_titles23
GROUP BY show_type;

## **Which content ratings are most common?**
```sql
SELECT show_type, rating, COUNT(*) AS total_count
FROM netflix_titles23
GROUP BY show_type, rating
ORDER BY total_count DESC
LIMIT 10;

## **Which movies were released in a specific year (e.g., 2020)?**
```sql
SELECT * FROM netflix_titles23
WHERE show_type = 'Movie' AND release_year = 2020;

## **Which 5 countries contribute the most content to Netflix?**

SELECT country, COUNT(*) AS total_content
FROM netflix_titles23
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

## **Which movie has the longest runtime on Netflix?**
SELECT * FROM netflix_titles23
WHERE show_type = 'Movie' 
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) = (
    SELECT MAX(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)) 
    FROM netflix_titles23
    WHERE show_type = 'Movie'
);

## **How many movies and TV shows were added in the last 5 years?**
SELECT * FROM netflix_titles23
WHERE STR_TO_DATE(date_added, '%d-%b-%y') >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

## **What content was directed by Rajiv Chilaka?**
SELECT * FROM netflix_titles23
WHERE director LIKE '%Rajiv Chilaka%';

## **Which TV Shows have more than 5 seasons?**
```sql
SELECT * FROM netflix_titles23
WHERE show_type = 'TV Show'
AND duration LIKE '%Season%'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

## **What are the most popular genres on Netflix?**
```sql
SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre FROM netflix_titles23 
    UNION ALL 
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) FROM netflix_titles23 
    UNION ALL 
    SELECT TRIM(SUBSTRING_INDEX(listed_in, ',', -1)) FROM netflix_titles23
) genre_list
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_content DESC;

## **Which years had the highest content releases in Japan?**
```sql
SELECT year, 
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM netflix_titles23 WHERE country = 'Japan') * 100, 2) AS avg_content_per_year
FROM netflix_titles23
WHERE country = 'Japan'
GROUP BY year
ORDER BY year DESC
LIMIT 5;

## **How many documentary movies are available on Netflix?**
```sql
SELECT * FROM netflix_titles23
WHERE listed_in LIKE '%Documentaries%';
Which movies and TV shows have no director assigned?
SELECT * FROM netflix_titles23
WHERE director IS NULL OR director = '';

## **How many movies has Salman Khan appeared in the last 10 years?**
```sql
SELECT * FROM netflix_titles23
WHERE casts LIKE '%Salman Khan%' 
AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

## **Who are the top 10 actors in Indian Netflix content?**
```sql
WITH RECURSIVE actor_split AS (
    SELECT show_id, country, 
           TRIM(SUBSTRING_INDEX(casts, ',', 1)) AS actor, 
           TRIM(SUBSTRING_INDEX(casts, ',', -1)) AS remaining_casts 
    FROM netflix_titles23 
    WHERE country LIKE '%India%' 
    UNION ALL 
    SELECT show_id, country, 
           TRIM(SUBSTRING_INDEX(remaining_casts, ',', 1)), 
           TRIM(SUBSTRING_INDEX(remaining_casts, ',', -1)) 
    FROM actor_split 
    WHERE remaining_casts LIKE '%,%'
) 
SELECT actor, COUNT(*) AS total_content 
FROM actor_split 
WHERE actor IS NOT NULL AND actor <> '' 
GROUP BY actor 
ORDER BY total_content DESC 
LIMIT 10;

## **How many Movies & TV Shows are added each year and month?**
```sql
SELECT EXTRACT(YEAR FROM STR_TO_DATE(date_added, '%d-%b-%y')) AS year,
       EXTRACT(MONTH FROM STR_TO_DATE(date_added, '%d-%b-%y')) AS month,
       show_type, COUNT(*) AS content_count
FROM netflix_titles23
WHERE date_added IS NOT NULL
GROUP BY year, month, show_type
ORDER BY year DESC, month DESC;
