/*SQL JOINs*/

/*pulling all the data from the accounts table, and all the data from the orders table*/
SELECT
	*
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id;

/*pulling standard_qty, gloss_qty, and poster_qty from the orders table, and the website and the primary_poc from the accounts table*/
SELECT
	a.id,
	o.standard_qty,
	o.gloss_qty,
	o.poster_qty,
	a.website,
	a.primary_poc
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
ORDER BY a.id;

/*Provide a table for all web_events associated with account name of Walmart. There should be three columns. Be sure to include the primary_poc, time of the event, and the channel for each event. Additionally, you might choose to add a fourth column to assure only Walmart events were chosen.*/
SELECT
	w.channel,
	w.occurred_at,
	a.primary_poc,
	a.name
FROM web_events AS w
JOIN accounts AS a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

/*Provide a table that provides the region for each sales_rep along with their associated accounts. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.*/
SELECT
	r.name AS region,
	s.name AS sales_rep,
	a.name AS account
FROM sales_reps AS s
JOIN region AS r
ON s.region_id = r.id
JOIN accounts AS a
ON s.id = a.sales_rep_id
ORDER BY a.name ASC;

/*Provide the name for each region for every order, as well as the account name and the unit price they paid. Your final table should have 3 columns: region name, account name, and unit price. A few accounts have 0 for total, so I divided by (total + 0.01) to assure not dividing by zero.*/
SELECT
	o.id AS "Order ID",
	r.name AS "Region Name",
	a.name AS "Account Name",
	o.total_amt_usd / (o.total + 0.01) AS "Unit Price"
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
JOIN sales_reps AS s
ON a.sales_rep_id = s.id
JOIN region AS r
ON s.region_id = r.id;

/*Provide a table that provides the region for each sales_rep along with their associated accounts; only for accounts where the sales rep has a first name starting with S (or last name startinf with K) and in the Midwest region. Your final table should include three columns: the region name, the sales rep name, and the account name. Sort the accounts alphabetically (A-Z) according to account name.*/
SELECT
	r.name AS region_name,
	s.name AS sales_rep,
	a.name AS account
FROM sales_reps AS s
JOIN region AS r 
ON s.region_id = r.id 
AND r.name = 'Midwest'
AND (s.name LIKE 'S%'
OR s.name LIKE '% K%')
JOIN accounts AS a 
ON s.id = a.sales_rep_id
ORDER BY a.name ASC;

/*Provide the name for each region for every order, as well as the account name and the unit price they paid (total_amt_usd/total) for the order. However, you should only provide the results if the standard order quantity exceeds 100 and the poster order quantity exceeds 50. Your final table should have 3 columns: region name, account name, and unit price. Sort for the largest unit price first. In order to avoid a division by zero error, adding .01 to the denominator here is helpful (total_amt_usd/(total+0.01).*/
SELECT
	r.name AS region_name,
	a.name AS account,
	o.total_amt_usd / (o.total + 0.01) AS unit_price
FROM sales_reps AS s
JOIN region AS r 
ON s.region_id = r.id 
JOIN accounts AS a 
ON s.id = a.sales_rep_id
JOIN orders AS o
ON a.id = o.account_id
AND o.standard_qty > 100
AND o.poster_qty > 50
ORDER BY unit_price DESC;

/*What are the different channels used by account id 1001? Your final table should have only 2 columns: account name and the different channels.*/
SELECT DISTINCT
	a.name AS account,
	w.channel
FROM accounts AS a
JOIN web_events AS w
ON a.id = w.account_id
AND a.id = '1001';

/*Find all the orders that occurred in 2015. Your final table should have 4 columns: occurred_at, account name, order total, and order total_amt_usd.*/
SELECT
	o.occurred_at,
	a.name AS account,
	o.total,
	o.total_amt_usd
FROM orders AS o
JOIN accounts AS a
ON o.account_id = a.id
AND DATE_PART('year', o.occurred_at) = '2015';


