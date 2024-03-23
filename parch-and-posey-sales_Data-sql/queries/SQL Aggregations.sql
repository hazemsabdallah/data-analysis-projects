/*SQL Aggregations*/

/*Find the standard_amt_usd per unit of standard_qty paper. To use AVG, one must get rid of 0 quantities.*/
SELECT
	SUM(standard_amt_usd) / SUM(standard_qty) AS st_price_per_unit
FROM orders;

SELECT
	AVG(standard_amt_usd / standard_qty) AS st_price_per_unit
FROM orders
WHERE standard_qty != 0;

/*When was the earliest order ever placed? You only need to return the date. In addition, try performing the same query as in question 1 without using an aggregation function.*/
SELECT
	MIN(occurred_at) AS earliest_date
FROM orders;

SELECT
	occurred_at AS earliest_date
FROM orders
ORDER BY occurred_at ASC
LIMIT 1;

/*What is the MEDIAN total_usd spent on all orders?*/
WITH t1 AS(
	SELECT
		COUNT(*) 
	FROM orders
	),
t2 AS(
	SELECT
		total_amt_usd AS median
	FROM orders
	ORDER BY median
	LIMIT 2
	OFFSET ((SELECT * FROM t1)/2)-1
	),
t3 AS(
	SELECT
		AVG(median)
	FROM t2
	),
t4 AS(
	SELECT
		total_amt_usd AS median
	FROM orders
	ORDER BY median
	LIMIT 1
	OFFSET ((SELECT * FROM t1)/2)-1
	)
SELECT
	CASE WHEN count % 2 = 0
	THEN (SELECT * FROM t3)
	ELSE (SELECT * FROM t4)
	END AS median
FROM t1;

/*Which account (by name) placed the earliest order? Your solution should have the account name and the date of the order.*/
WITH t1 AS(
	SELECT
		MIN(occurred_at) AS earliest_date
	FROM orders
	)
SELECT
	a.name AS account,
	o.occurred_at AS date
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
JOIN t1
ON t1.earliest_date = o.occurred_at;

/*Find the total sales in usd for each account. You should include two columns - the total sales for each company's orders in usd and the company name.*/
SELECT
	a.name AS account,
	SUM(o.total_amt_usd) AS total_sales
FROM accounts AS a
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_sales DESC;

/*Via what channel did the most recent (latest) web_event occur, which account was associated with this web_event? Your query should return only three values - the date, channel, and account name.*/
SELECT
	w.occurred_at,
	w.channel,
	a.name AS account
FROM web_events AS w
JOIN accounts AS a
ON a.id = w.account_id
ORDER BY w.occurred_at DESC
LIMIT 1;

/*Find the total number of times each type of channel from the web_events was used. Your final table should have two columns - the channel and the number of times the channel was used.*/
SELECT
	channel,
	COUNT(*)
FROM web_events
GROUP BY channel
ORDER BY count DESC;

/*Who was the primary contact associated with the earliest web_event?*/
SELECT
	a.primary_poc
FROM web_events AS w
LEFT JOIN accounts AS a
ON a.id = w.account_id
JOIN (SELECT MIN(occurred_at) AS earliest FROM web_events) AS sub
ON sub.earliest = w.occurred_at;

/*What was the smallest order placed by each account in terms of total usd. Provide only two columns - the account name and the total usd. Order from smallest dollar amounts to largest.*/
SELECT
	a.name AS account,
	MIN(o.total_amt_usd) AS smallest_order
FROM accounts AS a
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY account
ORDER BY smallest_order;

/*Find the number of sales reps in each region. Your final table should have two columns - the region and the number of sales_reps. Order from fewest reps to most reps.*/
SELECT
	r.name AS region,
	COUNT(s.*) AS num_reps
FROM region AS r
JOIN sales_reps AS s
ON r.id = s.region_id
GROUP BY region;

/*For each account, determine the average amount of each type of paper they purchased across their orders. Your result should have four columns - one for the account name and one for the average quantity purchased for each of the paper types for each account.*/
SELECT
	a.name AS account,
	SUM(o.standard_qty) / COUNT(o.standard_qty) AS avg_std_qty,
	AVG(o.gloss_qty) AS avg_gloss_qty,
	AVG(o.poster_qty) AS avg_poster_qty
FROM accounts AS a
LEFT JOIN orders AS o
ON a.id = o.account_id
GROUP BY account;

/*Determine the number of times a particular channel was used in the web_events table for each sales rep. Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.*/
SELECT
	s.name AS sales_rep,
	w.channel,
	COUNT(w.channel) AS frequency
FROM sales_reps AS s
LEFT JOIN accounts AS a
ON a.sales_rep_id = s.id
JOIN web_events AS w
ON w.account_id = a.id
GROUP BY sales_rep, w.channel
ORDER BY frequency DESC;

/*Determine the number of times a particular channel was used in the web_events table for each region. Your final table should have three columns - the region name, the channel, and the number of occurrences. Order your table with the highest number of occurrences first.*/
SELECT
	r.name AS region,
	w.channel,
	COUNT(w.channel) AS frequency
FROM sales_reps AS s
FULL JOIN accounts AS a
ON a.sales_rep_id = s.id
FULL JOIN web_events AS w
ON w.account_id = a.id
FULL JOIN region AS r
ON r.id = s.region_id
GROUP BY region, w.channel
ORDER BY frequency DESC;

/*Have any sales reps worked on more than one account?*/
SELECT
	s.name sales_rep,
	COUNT(a.*) AS accounts_num
FROM sales_reps AS s
LEFT JOIN accounts AS a
ON s.id = a.sales_rep_id
GROUP BY sales_rep
ORDER BY accounts_num ASC;

/*How many of the sales reps have more than 5 accounts that they manage?*/
WITH t1 AS(
	SELECT
		sales_rep_id,
		COUNT(*) AS accounts_count
    FROM accounts
    GROUP BY sales_rep_id
    HAVING COUNT(*) > 5
    )
SELECT
	COUNT(*)
FROM t1;

/*How many accounts have more than 20 orders?*/
SELECT
	account_id,
	COUNT(*) AS num_orders
FROM orders
GROUP BY account_id
HAVING COUNT(*) > 20
ORDER BY num_orders;

/*Which account has the most orders?*/
SELECT
	a.name AS account,
	COUNT(o.*) AS num_orders 
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY account
ORDER BY num_orders DESC
LIMIT 1;

/*Which accounts spent more than 30,000 usd total across all orders?*/
SELECT
	a.name AS account,
	SUM(o.total_amt_usd) AS total_spent
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY account
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent ASC;

/*Which accounts spent less than 1,000 usd total across all orders?*/
SELECT
	a.id,
	a.name AS account,
	SUM(o.total_amt_usd) AS total_spent
FROM orders AS o
RIGHT JOIN accounts AS a
ON o.account_id = a.id
GROUP BY a.id, account
HAVING SUM(o.total_amt_usd) < 1000
OR SUM(o.total_amt_usd) IS NULL;

/*Which account has spent the most with us?*/
SELECT
	a.name AS account,
	SUM(o.total_amt_usd) AS total_spent
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
GROUP BY account
ORDER BY total_spent DESC
LIMIT 1;

/*Which accounts used facebook as a channel to contact customers more than 6 times?*/
SELECT
	a.name AS account,
	w.channel,
	COUNT(w.*) AS contact_freq
FROM web_events AS w
JOIN accounts AS a
ON a.id = w.account_id
WHERE channel = 'facebook'
GROUP BY account, w.channel
HAVING COUNT(w.*) > 6
ORDER by contact_freq DESC;

/*Which channel was most frequently used by most accounts?*/
WITH t1 AS(
	SELECT DISTINCT
		account_id,
		channel
	FROM web_events
	)
SELECT
	channel,
	COUNT(*) AS account_usage
FROM t1
GROUP BY channel
ORDER BY account_usage DESC;









/*Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?*/
SELECT
	DATE_TRUNC('year', occurred_at) AS year,
	SUM(total_amt_usd) AS toatal_sales
FROM orders AS o
GROUP BY year
ORDER BY total_sales;

/*Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?*/
SELECT
	DATE_PART('month', occurred_at) AS month,
	SUM(total_amt_usd) AS toatal_sales
FROM orders AS o
GROUP BY month
ORDER BY total_sales DESC
LIMIT 1;

SELECT
	DATE_PART('month', occurred_at) AS month,
	COUNT(*) AS month_coverage
FROM orders AS o
GROUP BY month
ORDER BY month;

SELECT
	DATE_PART('month', occurred_at) AS month,
	SUM(total_amt_usd) total_sales
FROM orders AS o
WHERE DATE_PART('year', occurred_at) NOT IN (2013, 2017)
GROUP BY month
ORDER BY total_sales DESC;

/*Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?*/
SELECT
	DATE_TRUNC('year', occurred_at) AS year,
	COUNT(*) AS num_orders
FROM orders AS o
GROUP BY year
ORDER BY year;

/*In which month of which year did Walmart spend the most on gloss paper in terms of dollars?*/
SELECT
	DATE_TRUNC('month', o.occurred_at) AS month,
	a.name AS account,
	SUM(o.gloss_amt_usd) AS gloss_sales_amt
FROM orders AS o
JOIN accounts AS a
ON a.id = o.account_id
AND a.name = 'Walmart'
GROUP BY month, account
ORDER BY gloss_sales_amt DESC
LIMIT 1;











/*Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.*/
SELECT
	COUNT(*) orders_count,
	CASE WHEN total >= 2000
	THEN 'At Least 2000'
	WHEN total < 2000
	AND total >= 1000
	THEN 'Between 1000 and 2000'
	ELSE 'Less than 1000'
	END AS qty_flag
FROM orders
GROUP BY qty_flag;

/*We would like to understand 3 different levels of customers based on the amount associated with their purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first. Obtain the total amount spent by customers only in 2016 and 2017*/
SELECT
	a.name AS account,
	SUM(o.total_amt_usd) AS lifetime_value,
	CASE WHEN SUM(o.total_amt_usd) > 200000
	THEN 'high'
	WHEN SUM(o.total_amt_usd) BETWEEN 100000 AND 200000
	THEN 'medium'
	ELSE 'low'
	END AS ltv_flag
FROM orders AS o
JOIN accounts AS a
ON a.id = o.account_id
AND DATE_PART('year', o.occurred_at) IN (2016, 2017)
GROUP BY account
ORDER BY lifetime_value DESC;

/* We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. You might see a few upset sales people by this criteria!*/
SELECT
	s.name sales_rep,
	COUNT(o.*) num_orders,
	SUM(o.total_amt_usd) total_spent,
	CASE WHEN COUNT(o.*) > 200
	OR SUM(o.total_amt_usd) >750000
	THEN 'top'
	WHEN COUNT(o.*) > 150
	OR SUM(o.total_amt_usd) >500000
	THEN 'middle'
	ELSE 'low'
	END AS performance
FROM sales_reps AS s
LEFT JOIN accounts AS a 
ON a.sales_rep_id = s.id
JOIN orders AS o
ON o.account_id = a.id
GROUP BY sales_rep
ORDER BY performace DESC;

