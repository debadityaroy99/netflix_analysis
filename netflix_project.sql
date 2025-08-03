CREATE TABLE NETFLIX_DETAILS(
							show_id	VARCHAR(6) PRIMARY KEY,
                            category VARCHAR(10),
                            title	VARCHAR(110),
                            director	VARCHAR(209),
                            crew	VARCHAR(772),
                            country	VARCHAR(180),
                            date_added	VARCHAR(50),
                            release_year	INT,
                            rating	VARCHAR(10),
                            duration	VARCHAR(20),
                            listed_in	VARCHAR(500),
                            description VARCHAR(300)
);
SELECT DISTINCT CATEGORY FROM NETFLIX;

-- 1. Count the number of Movies vs TV Shows
	SELECT CATEGORY,COUNT(*) AS COUNT FROM NETFLIX GROUP BY 1;
-- 2. Find the most common rating for movies and TV shows\
		-- USING CTE
	WITH ratingCount AS(
		SELECT CATEGORY,RATING,COUNT(*) AS COUNT FROM NETFLIX GROUP BY CATEGORY,RATING
    ),
    rankedrating AS(
    SELECT CATEGORY,RATING,RANK() OVER (PARTITION BY CATEGORY ORDER BY COUNT DESC) AS POSITION FROM RATINGCOUNT
    )
    SELECT CATEGORY,RATING FROM RANKEDRATING WHERE POSITION=1;
		-- USING THE BRUTE-FORCE METHOD
	SELECT CATEGORY,RATING FROM (
    SELECT CATEGORY,RATING,COUNT(RATING),RANK() OVER (PARTITION BY CATEGORY ORDER BY COUNT(RATING) DESC) AS COUNT FROM NETFLIX GROUP BY CATEGORY,RATING ORDER BY 1,3 DESC
    )  AS T1 WHERE COUNT=1;
    
-- 3. List all movies released in a specific year (e.g., 2020)
	  SELECT TITLE FROM NETFLIX WHERE release_year=2020;
-- 4. Find the top 5 countries with the most content on Netflix
		WITH countrylist as(
			SELECT STRING_TO_ARRAY(COUNTRY,',') as list FROM NETFLIX
		),
		COUNTRYCOUNT AS(
			SELECT UNNEST(list),COUNT(*) from countrylist group by 1 order by 2 desc
		)
		SELECT * FROM countrycount limit 5
		
-- 5. Identify the longest movie	

		SELECT Title from netflix where duration=(select max(duration) from netflix)
		
-- 6. Find content added in the last 5 years

		WITH YEARLIST AS(
			SELECT TITLE,EXTRACT (YEAR FROM (TO_DATE(date_added,'MONTH DD,YY'))) AS YEAR,DATE_ADDED FROM NETFLIX
		),
		REQUIREDYEAR AS (
			SELECT EXTRACT(YEAR FROM (CURRENT_DATE-INTERVAL '5 YEARS')) AS REQUIRED
			)
			SELECT Y.TITLE,Y.YEAR,Y.DATE_ADDED FROM YEARLIST AS Y,REQUIREDYEAR AS R WHERE Y.YEAR=R.REQUIRED

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
		WITH DIRECTORLIST AS(
			SELECT TITLE,UNNEST(STRING_TO_ARRAY(DIRECTOR,',')) AS DIRECTORS FROM NETFLIX
		)
		SELECT TITLE,DIRECTORS FROM DIRECTORLIST WHERE DIRECTORS='Rajiv Chilaka'
		
-- 8. List all TV shows with more than 5 seasons
		Select title,duration from netflix where duration>'6 seasons' and duration like '%Seasons'
-- 9. Count the number of content items in each genre
		WITH genre as (
			SELECT UNNEST(STRING_TO_ARRAY(LISTED_IN,',')) AS GENRES FROM NETFLIX
		)
		SELECT GENRES,COUNT(GENRES) FROM GENRE GROUP BY 1 ORDER BY 2 DESC;
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
		WITH countries AS (
			SELECT TITLE,RELEASE_YEAR,UNNEST(STRING_TO_ARRAY(COUNTRY,',')) AS COUNTRY FROM NETFLIX
		),
		YEARS AS (
			SELECT RELEASE_YEAR,COUNT(*) FROM COUNTRIES WHERE COUNTRY='India' GROUP BY 1 ORDER BY 2 DESC
		)
		SELECT * FROM YEARS LIMIT 5
		SELECT N.* FROM NETFLIX AS N WHERE TITLE IN (
			SELECT TITLE FROM COUNTRIES WHERE COUNTRY='India'
		)
-- 11. List all movies that are documentaries
		WITH GENRE AS (
			SELECT TITLE,UNNEST(STRING_TO_ARRAY(LISTED_IN,','))AS GENRES FROM NETFLIX
		)
		SELECT TITLE,GENRES FROM GENRE WHERE GENRES='Documentaries'
-- 12. Find all content without a director
		SELECT TITLE FROM NETFLIX WHERE DIRECTOR IS NULL
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
		WITH ACTORS AS(
			SELECT  TITLE, UNNEST(STRING_TO_ARRAY(CREW,',')) AS ACTOR FROM NETFLIX
		)
		SELECT TITLE FROM ACTORS WHERE ACTOR='Salman Khan'
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
		WITH ACTORS AS(
			SELECT  TITLE, UNNEST(STRING_TO_ARRAY(CREW,',')) AS ACTOR FROM NETFLIX
		)
		SELECT ACTOR,COUNT(*) AS COUNT FROM ACTORS GROUP BY 1 ORDER BY 2 DESC LIMIT 10
-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
select title,
	CASE 
		WHEN DESCRIPTION LIKE '% kill %' OR DESCRIPTION LIKE '% violence %'  THEN 'Bad'
		ELSE 'Good'
	END AS genre,DESCRIPTION
FROM NETFLIX

