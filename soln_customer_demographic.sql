--  Customer Demographics Analysis
-- 1. Total Customers in each state
SELECT   state,
	     COUNT(consumer_id) as total_customers
FROM 	 customer_details
GROUP BY 1
ORDER BY 2 DESC;


-- 2. Total Customers in each city 
SELECT   city,
	     COUNT(consumer_id) as total_customers
FROM 	 customer_details
GROUP BY 1
ORDER BY 2 DESC;	

-- 3. Budget level of customers
SELECT   budget,
	     COUNT(consumer_id) as total_customers
FROM 	 customer_details
WHERE 	 budget is not null
GROUP BY 1;

-- 4. Total Smokers by Occupation
SELECT   occupation,
	     COUNT(consumer_id) as smokers
FROM 	 customer_details
WHERE 	 smoker = 'Yes'
GROUP BY 1;

-- 5. Drinking level of student
SELECT   drink_level,
	 	 COUNT(consumer_id) as student_count
FROM 	 customer_details
WHERE 	 occupation = 'Student' and occupation is not null
GROUP BY 1;

-- 6. Transportation methods of customers
SELECT   transportation_method,
	 	 COUNT(consumer_id) as total_customers
FROM 	 customer_details
WHERE 	 transportation_method is not null	
GROUP BY 1
ORDER BY 2 DESC;

-- 7. Adding Age Bucket Column
ALTER TABLE customer_details 
ADD COLUMN  age_bucket Varchar(50);

-- 8. Updating the Age Bucket column with case when condition
UPDATE customer_details
SET age_bucket = 
		 CASE WHEN age > 60 then '61 and Above'
		      WHEN age > 40 then '41 - 60'	
		      WHEN age > 25 then '26 - 40'
		      WHEN age >= 18 then '18 - 25'
		    END
WHERE age_bucket is null;

-- 9. Total customers in each age bucket				  
SELECT   age_bucket,
	     COUNT(consumer_id) as total_customers 
FROM 	 customer_details
GROUP BY 1
ORDER BY 1;

-- 10. Total customers COUNT & smokers COUNT in each age percent
SELECT   age_bucket,
	     COUNT(consumer_id) as total,
	     COUNT(CASE WHEN smoker = 'Yes' THEN consumer_id END) as smokers_count
FROM 	 customer_details
GROUP BY 1
ORDER BY 1;

-- 11. Top 10 preferred cuisines
SELECT   preferred_cuisine,
	 	 COUNT(consumer_id) AS total_customers
FROM 	 customer_preference	
GROUP BY 1
ORDER BY 2 DESC
LIMIT    10;

-- 12. Preferred cuisines of each customer
SELECT   consumer_id,
		 COUNT(preferred_cuisine) AS total_cuisines,
	     STRING_AGG(preferred_cuisine, ',') as cuisines
FROM 	 customer_preference
GROUP BY 1
ORDER BY 2 DESC;

-- 13. Customer Budget analysis for each cuisine
SELECT   b.preferred_cuisine,
		 SUM(CASE WHEN a.budget = 'High' Then 1 Else 0 END) AS High,
		 SUM(CASE WHEN a.budget = 'Medium' Then 1 Else 0 END) AS Medium,
		 SUM(CASE WHEN a.budget = 'Low' Then 1 Else 0 END) AS Low
FROM 	 customer_details a JOIN customer_preference b USING(customer_id)
GROUP BY 1
ORDER BY 1;

-- 14. Finding out number of preferred cuisine in each state
SELECT   a.state,
	     COUNT(b.preferred_cuisine) AS count
FROM 	 customer_details a JOIN customer_preference b USING(consumer_id)
GROUP BY 1
ORDER BY 2 DESC;