-- Full hulu dataset

SELECT *
	FROM hulu
;

/*
The full dataset of HuluUpdated.csv
*/


-- Hulu_company_ratings dataset query

WITH company_top_ratings AS (
	SELECT
	show_company_name AS company,
	MAX(show_rating) AS rating
	FROM hulu
	GROUP BY company
),
company_lowest_ratings AS (
	SELECT
	show_company_name AS company,
	MIN(show_rating) AS rating
	FROM hulu
	GROUP BY company
),
company_average_ratings AS (
	SELECT
	show_company_name AS company,
	AVG(show_rating) AS rating
	FROM hulu
	GROUP BY company
),
company_top_show AS (
	SELECT
	top.company AS company,
	h.show_canonical_name AS show_name,
	top.rating AS max_rating
	FROM company_top_ratings AS top
	JOIN hulu AS h
		ON h.show_rating = top.rating
),
company_lowest_show AS (
	SELECT
	lowest.company AS company,
	h.show_canonical_name AS show_name,
	lowest.rating AS min_rating
	FROM company_lowest_ratings AS lowest
	JOIN hulu AS h
		ON h.show_rating = lowest.rating
),
company_show_count AS (
	SELECT
	show_company_name AS company,
	COUNT(show_id) AS show_count
	FROM hulu
	GROUP BY company
),
company_ratings AS (
	SELECT
	average.company,
	show_count.show_count AS number_of_shows,
	average.rating AS average_rating,
	top.show_name AS top_show_name,
	top.max_rating AS top_rating,
	lowest.show_name AS lowest_show_name,
	lowest.min_rating AS lowest_rating
	FROM company_average_ratings AS average
	JOIN company_show_count AS show_count
		ON show_count.company = average.company
	JOIN company_top_show AS top
		ON top.company = average.company
	JOIN company_lowest_show AS lowest
		ON lowest.company = average.company
	ORDER BY average_rating DESC
)

SELECT
	*
	FROM company_ratings
	ORDER BY average_rating DESC
;

/*
This query results in the Hulu_company_ratings.csv dataset.
The resulting data shows each companys number of shows, the average rating for those shows, higest rated show along with its rating, and the lowest rated show and its rating.
*/


--Hulu_ratings_teirs dataset query

WITH rating_teirs AS (
	SELECT
		CASE
			WHEN show_rating >= 4 THEN 'TOP'
			WHEN show_rating >= 3 THEN 'HIGH'
			WHEN show_rating >= 2 THEN 'LOW'
			WHEN show_rating >= 1 THEN 'BOTTOM'
			ELSE 'FAILING'
		END AS show_teir,
		AVG(show_rating) AS teir_average,
		COUNT(show_id) AS number_of_shows
		FROM hulu
		GROUP BY show_teir
),
show_teir_scores AS (
	SELECT
		show_teir,
		teir_average,
		number_of_shows,
		number_of_shows::float / (SELECT COUNT(show_id) FROM hulu) AS teir_score
	FROM rating_teirs
)

SELECT
	*
	FROM show_teir_scores
;

/*
This query results in the Hulu_ratings_teirs.csv dataset.
The resulting data splits ratings into 5 teirs to represent the 5 star rating system.
Each teir shows its average rating, number of shows of that teir, and the percentage of the shows within that teir against all shows within the hulu dataset.
*/


-- Hulu_genre_ratings dataset query

SELECT
	show_genre AS genre,
	AVG(show_rating) AS average_rating
	FROM hulu
	GROUP BY genre
	ORDER BY average_rating DESC
;

/*
This query results in the Hulu_genre_ratings.csv dataset.
The results give each genre and gets the average rating for the genre.
*/