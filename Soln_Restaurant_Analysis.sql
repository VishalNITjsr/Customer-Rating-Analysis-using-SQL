-- Restaurant_Analysis
-- 1. Total restaurants in each state
SELECT   state,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Total restaurants in each city
SELECT   city,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Restaurants COUNT by alcohol service
SELECT   alcohol_service,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

--  4. Restaurants Count by Smoking Allowed
SELECT   smoking_allowed,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Alcohol & Smoking analysis
SELECT   alcohol_service,
         smoking_allowed,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 6. Restaurants COUNT by Price
SELECT   price,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- 7. Restaurants COUNT by packing
SELECT   parking,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- 8. Count of Restaurants by cuisines
SELECT   cuisine,
	     COUNT(restaurant_id) as total_restaurants
FROM 	 restaurant_cuisines
GROUP BY 1
ORDER BY 2 DESC	
LIMIT    5;			  

-- 9. Preferred cuisines of each customer
SELECT   name as restaurant_name,
	     COUNT(cuisine) as total_cuisines,
	     GROUP_CONCAT(cuisine, ',') as cuisines
FROM 	 restaurant_cuisines as a JOIN restaurants as b USING(restaurant_id)
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Restaurant Price-Analysis for each cuisine
SELECT   cuisine,
	     SUM(CASE WHEN price = 'High' THEN 1 ELSE 0 END) as High,
         SUM(CASE WHEN price = 'Medium' THEN 1 ELSE 0 END) as Medium,
	     SUM(CASE WHEN price = 'Low' THEN 1 ELSE 0 END) as Low
FROM 	 restaurant_cuisines as a JOIN restaurants as b USING(restaurant_id)
GROUP BY 1
ORDER BY 1;

-- 11. Finding out COUNT of each cuisine in each state
SELECT   cuisine,
	     SUM(CASE WHEN state = 'Morelos' THEN 1 ELSE 0 END) as Morelos,
	     SUM(CASE WHEN state = 'San Luis Potosi' THEN 1 ELSE 0 END) as San_Luis_Potosi,
	     SUM(CASE WHEN state = 'Tamaulipas' THEN 1 ELSE 0 END) as Tamaulipas
FROM 	 restaurant_cuisines as a JOIN restaurants as b USING(restaurant_id)
GROUP BY 1
ORDER BY 1;

