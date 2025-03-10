-- Rating Analysis
-- 1. Ratings given by customer for restaurants
SELECT   b.consumer_id,
	     a.name,
	     b.overall_rating,
	     b.food_rating,
	     b.service_rating
FROM     restaurants as a JOIN customer_ratings as b USING(restaurant_id)
ORDER BY b.restaurant_id;

-- 2. Average ratings of each restaurant including its cuisine type
SELECT   a.name,
	     ROUND(AVG(b.overall_rating),2)as overall_Rating,
	     ROUND(AVG(b.food_rating),2)as food_rating,
	     ROUND(AVG(b.service_rating),2)as service_rating,
	     c.cuisine
FROM     restaurants as a JOIN customer_ratings as b USING(restaurant_id) 
				          JOIN restaurant_cuisines AS c USING(restaurant_id)
GROUP BY 1, 5
ORDER BY 1;

-- 3. Creating new columns for sentiment analysis
ALTER TABLE customer_ratings ADD COLUMN overall_senti Varchar(50);
ALTER TABLE customer_ratings ADD COLUMN food_senti Varchar(50);
ALTER TABLE customer_ratings ADD COLUMN service_senti Varchar(50);

-- 4. Updating the new columns with the sentiments
UPDATE customer_ratings
SET overall_sentiment = 
		CASE WHEN overall_rating = 0 then 'Negative'
			 WHEN overall_rating = 1 then 'Neutral'	
			 WHEN overall_rating = 2 then 'Positive'
		  END
WHERE overall_sentiment is null;

UPDATE customer_ratings
SET food_sentiment = 
		CASE WHEN food_rating = 0 then 'Negative'
		     WHEN food_rating = 1 then 'Neutral'	
		     WHEN food_rating = 2 then 'Positive'
		  END
WHERE food_sentiment is null;

UPDATE customer_ratings
SET service_sentiment = 
		CASE WHEN service_rating = 0 then 'Negative'
			 WHEN service_rating = 1 then 'Neutral'	
			 WHEN service_rating = 2 then 'Positive'
		  END
WHERE service_sentiment is null;

SELECT * 
FROM   customer_ratings;

-- 5. Conduct a sentimental analysis of total count of customers
CREATE VIEW overall AS
	SELECT   overall_sentiment, COUNT(consumer_id) AS total_customers
	FROM     customer_ratings
	GROUP BY 1;


CREATE VIEW food AS 
	SELECT   food_sentiment,
			 count(consumer_id) as total_customers
	FROM 	 customer_ratings
	GROUP BY 1;


CREATE VIEW service AS 
	SELECT   service_sentiment,
			 count(consumer_id) as total_customers
	FROM 	 customer_ratings
	GROUP BY 1;
    
    SELECT a.overall_sentiment as sentiment,
	   a.total_customers as overall_Rating,
	   b.total_customers as food_Rating,
	   c.total_customers as service_Rating
FROM   overall as a JOIN food as b ON a.overall_sentiment = b.food_sentiment
					JOIN service as c ON a.overall_sentiment = c.service_sentiment;

-- 6. List of Customers visiting local or outside restaurants
SELECT a.consumer_id,
	   b.city as customer_city,
	   c.name,
	   c.city as restaurant_city,
	   a.overall_sentiment,
	   a.food_sentiment,
	   a.service_sentiment,
	   CASE WHEN b.city = c.city THEN 'Local' ELSE 'Outside' END as location_preference
FROM   customer_ratings as a JOIN customer_details as b USING(consumer_id)
							 JOIN restaurants as c USING(restaurant_id);
                             
-- 7. Count of customers visiting local and outside restaurants   
SELECT location_preference,
	   COUNT(*) as total_customers,
	   COUNT(DISTINCT id) as distinct_customers
FROM 	(    
	SELECT a.consumer_id as id,
		   b.city as customer_city,
		   c.name,
		   c.city as restaurant_city,
		   a.overall_sentiment,
		   a.food_sentiment,
		   a.service_sentiment,
		   CASE WHEN b.city = c.city THEN 'Local' ELSE 'Outside' END as Location_preference
	FROM   customer_ratings as a JOIN customer_details as b USING(consumer_id)
		  						 JOIN restaurants as c USING(restaurant_id)
		) as cte
GROUP BY 1	;			                          
                             
-- 8. Trend of customers visiting outside restaurants 
SELECT customer_id,
	   customer_city,
	   restaurant_city,
	   concat_ws(' - ',customer_city , restaurant_city) as direction,
	   restaurant_name		
FROM 	( 
	SELECT a.consumer_id as customer_id,
		   b.city as customer_city,
		   c.name as restaurant_name,
		   c.city as restaurant_city,
	       a.overall_sentiment,
	       a.food_sentiment,
	       a.service_sentiment,
	  	   CASE WHEN b.city = c.city THEN 'Local' ELSE 'Outside' END as location_preference
	FROM   customer_ratings as a JOIN customer_details as b USING(consumer_id)
								 JOIN restaurants as c USING(restaurant_id)
		) as cte
WHERE  location_preference = 'Outside';

-- 9. Count of direction trend from above query	
SELECT direction,
	   COUNT(customer_id) as total_customers

FROM  (  
	SELECT customer_id,
		   customer_city,
		   restaurant_city,
		   concat_ws(' - ',customer_city , restaurant_city) as direction,
		   restaurant_name
		
	FROM  (  
		SELECT a.consumer_id as customer_id,
			   b.city as customer_city,
			   c.name as restaurant_name,
			   c.city as restaurant_city,
			   a.overall_sentiment,
			   a.food_sentiment,
			   a.service_sentiment,
			   CASE WHEN  b.city = c.city THEN 'Local' ELSE 'Outside' END as Location_preference
		FROM   customer_ratings as a JOIN customer_details as b USING(consumer_id)
									 JOIN restaurants as c USING(restaurant_id)
									 
			) as cte
	WHERE  Location_preference = 'Outside' ) cte2
GROUP BY 1;	                              

-- 10. Cuisine preferences vs cuisine consumed
SELECT  a.consumer_id,
	    GROUP_CONCAT(b.preferred_cuisine,',') as customer_preferences,
	    d.name,
		c.cuisine as restaurant_cuisine
FROM    customer_ratings as a JOIN customer_preference as b USING(consumer_id)
							  JOIN restaurant_cuisines as c USING(restaurant_id)
							  JOIN restaurants as d USING(restaurant_id)
GROUP BY 1, 3, 4;

-- 11. Best restaurants for each cuisines by different ratings
CREATE VIEW average_analysis as 
	SELECT   a.name,
			 ROUND(AVG(b.overall_rating), 2) as overall_Rating,
			 ROUND(AVG(b.food_rating), 2) as food_rating,
			 ROUND(AVG(b.service_rating), 2) as service_rating,
			 c.cuisine
	FROM     restaurants as a JOIN customer_ratings as b USING(restaurant_id)
							  JOIN restaurant_cuisines AS c USING(restaurant_id)
	GROUP BY 1, 5
	ORDER BY 5;

	
CREATE VIEW best  as 
	SELECT cuisine,
		   first_value(name) OVER(partition by cuisine ORDER BY overall_rating desc) as best_overall,
		   first_value(name) OVER(partition by cuisine ORDER BY food_rating desc) as best_for_food,
		   first_value(name) OVER(partition by cuisine ORDER BY service_rating desc) as best_for_service
	FROM   average_analysis;
    
--     12. Worst restaurants for each cuisines by different ratings
CREATE VIEW count_cuisines as 
	SELECT   cuisine,
			 COUNT(cuisine)	as count
	FROM     average_analysis
	GROUP BY 1;

		
CREATE VIEW worst as 
	SELECT cuisine,
		   first_value(name) OVER(PARTITION BY cuisine ORDER BY overall_rating) as worst_overall,
		   first_value(name) OVER(PARTITION BY cuisine ORDER BY food_rating) as worst_for_food,
		   first_value(name) OVER(PARTITION BY cuisine ORDER BY service_rating) as worst_for_service	
	FROM    ( 	
			SELECT   a.name,
				     ROUND(AVG(a.overall_rating), 2)as overall_Rating,
				     ROUND(AVG(a.food_rating), 2)as food_rating,
				     ROUND(AVG(a.service_rating), 2)as service_rating,
				     a.cuisine,
				     cc.count
			FROM     average_analysis as a JOIN count_cuisines as cc USING(cuisine)
			WHERE    cc.count > 1	
			GROUP BY 1, 5, 6
			ORDER BY 5
		) as least;
        
-- 13. Total customers with highest ratings in all different criteria
SELECT COUNT(consumer_id) as total_customers
FROM   customer_ratings
WHERE  overall_rating = 2 and food_rating = 2 and service_rating = 2;