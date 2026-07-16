CREATE TABLE Netflix
(
    show_id	VARCHAR(6),
    type	VARCHAR(10),
    title VARCHAR(150),
	director VARCHAR(208),
    casts VARCHAR(1000),	
    country	VARCHAR(150),
	date_added VARCHAR(50),	
	release_year INT,	
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)

);

SELECT *
FROM Netflix

SELECT
COUNT(*) as total_content
FROM Netflix

SELECT
DISTINCT type
FROM Netflix;

SELECT *
FROM Netflix


--15 Business Problems

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) as Total_Content
FROM Netflix
GROUP BY type



-- 2. Find the most common rating for movies and TV shows
SELECT type, rating
from (
SELECT type, rating, COUNT(*) AS TotalCount,
RANK() OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS Ranking
from Netflix
GROUP BY type,rating
) as t1

where ranking = 1



-- 3. List all movies released in a specific year (e.g., 2020)
 SELECT *
 FROM Netflix
 WHERE type = 'Movie'
 AND release_year = '2020'
 


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
      UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, 
      COUNT(show_id) as total_content
FROM Netflix
GROUP BY country
ORDER BY total_content Desc
LIMIT 5



-- 5. Identify the longest movie
SELECT * 
FROM Netflix
WHERE 
     type = 'Movie'
	 AND
	 duration = (SELECT MAX(duration) from Netflix)



-- 6. Find content added in the last 5 years
SELECT *, 
       TO_DATE(date_added, 'Month DD, YYYY')::DATE AS numerical_date
FROM Netflix 
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';



-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * 
FROM Netflix
WHERE director like '%Rajiv Chilaka%'


-- 8. List all TV shows with more than 5 seasons
SELECT *    
FROM Netflix
WHERE 
    type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1) :: numeric > 5


-- 9. Count the number of content items in each genre
SELECT 
       UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	   COUNT(show_id) as total_content
FROM Netflix
GROUP BY genre



-- 10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!
 SELECT 
     EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year , 
	 count(show_id) as yearly_content,
	 ROUND(
	 COUNT(show_id)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric *100
	 ,2) as avg_content_per_year

FROM Netflix
WHERE country = 'India'
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5



-- 11. List all movies that are documentaries
SELECT *    
FROM Netflix
WHERE listed_in ILIKE '%Documentaries%'



-- 12. Find all content without a director
SELECT *    
FROM Netflix
WHERE director IS NULL



--  3. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *    
FROM Netflix
WHERE casts ILIKE '%Salman Khan%'
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(show_id) as total_content
FROM Netflix
WHERE country ILIKE '%india%'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10



-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
WITH new_table
AS
(
SELECT 
*,   
     CASE 
	 WHEN  description ILIKE '%kill%'
	       OR
	       description ILIKE '%violence%'
		   THEN
		   'Bad_Content'
		   ELSE
		   'Good_Content'
		   END Category
FROM Netflix
)

SELECT 
     Category,
	 COUNT(*) AS total_count
FROM new_table	 
GROUP BY Category