SELECT * 
FROM walmart;

--Answering Business Problems

--1. What are the different payment methods, and how many transactions and items were sold with each method?
SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--2. Which category received the highest average rating in each branch?
WITH mycte AS (
	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY branch , category
)
SELECT * 
FROM mycte
WHERE rank = 1;

-- What is the busiest day of the week for each branch based on transaction volume?
SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY branch , day_name
	)
WHERE rank = 1;

--4.How many items were sold through each payment method?
SELECT 
	 payment_method,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

--5.What are the average, minimum, and maximum ratings for each category in each city?
SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY city, category 
ORDER BY city, category;

--6. What is the total profit for each category, ranked from highest to lowest?
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category;

--7.What is the most frequently used payment method in each branch?
WITH cte AS(
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY branch, payment_method
)

SELECT branch , payment_method , total_trans
FROM cte
WHERE rank = 1;

--8.How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
SELECT branch,
	COUNT(*) as trans_count,
	CASE
		WHEN EXTRACT(HOUR FROM (time :: time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM (time :: time)) BETWEEN  12  AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
FROM walmart 
GROUP BY branch , shift
ORDER BY branch ,trans_count DESC;

--9. Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue2023 AS (
	SELECT branch,
		SUM(total) AS total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date , 'DD/MM/YY')) = 2023
	GROUP BY branch
),
revenue2022 AS (
	SELECT branch,
		SUM(total) AS total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date , 'DD/MM/YY')) = 2022
	GROUP BY branch
)
SELECT r2.branch,
	   r2.total_revenue AS last_year_revenue,
		r1.total_revenue AS current_year_revenue,
	ROUND (
		100.0*((r2.total_revenue - r1.total_revenue)::numeric / r2.total_revenue::numeric)
		, 2
	) as perc_decrease
FROM revenue2023 r1
JOIN revenue2022 r2
	ON r1.branch = r2.branch
WHERE r2.total_revenue > r1.total_revenue
ORDER BY perc_decrease DESC
LIMIT 5;