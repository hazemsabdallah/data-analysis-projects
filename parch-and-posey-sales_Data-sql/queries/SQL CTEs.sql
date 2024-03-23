/*average number of events a day for each channel*/
SELECT
	channel,
	AVG(count) AS traffic_per_day
FROM
	(SELECT
		DATE_TRUNC('day', occurred_at) AS day,
		channel,
		COUNT(*)
	FROM web_events
	GROUP BY day, channel) AS sub
GROUP BY channel
ORDER BY traffic_per_day DESC;

SELECT
	COUNT(*) / COUNT(DISTINCT DATE_TRUNC('day', occurred_at)) AS avg_traffic,
	channel
FROM web_events
GROUP BY channel
ORDER BY avg_traffic DESC;

/*On the month of the first order ever placed, what other orders did occurr?*/
SELECT
	* 
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
	(SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

/*Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.*/
WITH t1 AS(
	SELECT
		r.name AS region,
		s.name AS sales_rep,
		SUM(o.total_amt_usd) AS total_sales
	FROM sales_reps AS s
	JOIN accounts AS a
	ON a.sales_rep_id = s.id
	JOIN orders AS o
	ON o.account_id = a.id
	JOIN region AS r
	ON r.id = s.region_id
	GROUP BY region, sales_rep
	)
SELECT
	*
FROM t1
WHERE total_sales IN
	(SELECT MAX(total_sales) FROM t1 GROUP BY region);

/*For the region with the largest of sales total_amt_usd, how many total orders were placed?*/
WITH t1 AS(
	SELECT
		SUM(o.total_amt_usd) AS total_sales,
		r.name AS region_t1
	FROM sales_reps AS s
	JOIN accounts AS a
	ON a.sales_rep_id = s.id
	JOIN orders AS o
	ON o.account_id = a.id
	JOIN region AS r
	ON r.id = s.region_id
	GROUP BY region_t1
	ORDER BY total_sales DESC
	LIMIT 1
	)
SELECT
	r.name AS region,
	COUNT(o.*) AS orders_count
FROM orders AS o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps AS s
ON s.id = a.sales_rep_id
JOIN region AS r
ON r.id = s.region_id
AND r.name =
	(SELECT region_t1 FROM t1)
GROUP BY region;

/*How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?*/
WITH t1 AS(
	SELECT
		account_id AS account_id_t1,
		SUM(standard_qty) AS standard_qty,
		SUM(total) AS total_qty_t1
	FROM orders
	GROUP BY account_id_t1
	ORDER BY standard_qty DESC
	LIMIT 1
	),
t2 AS(
	SELECT
		account_id,
		SUM(total) AS total_qty_t2
	FROM orders
	GROUP BY account_id
	HAVING SUM(total) >
		(SELECT total_qty_t1 FROM t1)
	)
SELECT
	COUNT(*) AS accounts_count
FROM t2;

/*What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.*/
WITH total_avg AS(
	SELECT
		AVG(total_amt_usd) AS order_avg
	FROM orders
	),
above_avg AS(
	SELECT
		account_id
	FROM orders
	GROUP BY account_id
	HAVING AVG(total_amt_usd) >
		(SELECT * FROM total_avg)
	),
ltv AS(
	SELECT
		account_id,
		SUM(total_amt_usd) AS ltv_spending
	FROM orders
	GROUP by account_id
	)
SELECT
	AVG(ltv_spending) AS ltv_avg
FROM ltv
WHERE account_id IN
	(SELECT * FROM above_avg);     

/*What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?*/
WITH t1 AS(
	SELECT
		account_id,
		SUM(total_amt_usd) AS total_spending
	FROM orders
	GROUP BY account_id
	ORDER BY total_spending DESC
	LIMIT 10
	)
SELECT
	AVG(total_spending) AS top10_avg_spending
FROM t1;

/*For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?*/
WITH t1 AS(
	SELECT
		a.name AS account_t1,
		w.channel,
		COUNT(w.*) AS events_count
	FROM web_events AS w
	JOIN accounts AS a
	ON w.account_id = a.id
	GROUP BY account_t1, channel
	),
t2 AS(
	SELECT
		a.name AS account,
		SUM(o.total_amt_usd) AS total_spending
	FROM accounts AS a
	JOIN orders AS o
	ON o.account_id = a.id
	GROUP BY account
	ORDER BY total_spending DESC
	LIMIT 1
	)
SELECT
	t1.* 
FROM t1
JOIN t2
ON t1.account_t1 = t2.account
ORDER BY events_count DESC;
