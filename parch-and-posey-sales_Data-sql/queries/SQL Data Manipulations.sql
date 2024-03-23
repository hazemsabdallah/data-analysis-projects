/*SQL Data Manipulation*/

/*In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. Pull these extensions and provide how many of each website type exist in the accounts table.*/
SELECT
	RIGHT(website, 3) AS website_type,
	COUNT(*) 
FROM accounts
GROUP BY website_type;

/*Create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?*/
WITH t1 AS(
	SELECT
		name,
		CASE WHEN LEFT(UPPER(name),1) BETWEEN 'A' AND 'Z'
		THEN 1
		ELSE 0
		END AS letter,
		CASE WHEN LEFT(UPPER(name),1) NOT BETWEEN 'A' AND 'Z'
		THEN 1
		ELSE 0
		END AS number
	FROM accounts
	)
SELECT
	SUM(letter) AS letters,
	SUM(number) AS numbers
FROM t1;

/*Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?*/
SELECT
	CASE WHEN LEFT(UPPER(name),1) IN ('A', 'E', 'I','O', 'U')
	THEN 'vowel'
	ELSE 'non vowel'
	END AS label,
	COUNT(*)
FROM accounts
GROUP BY label;

/*Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.*/
SELECT
	primary_poc,
	LEFT(primary_poc, STRPOS(primary_poc, ' ')-1) AS first_name,
	SUBSTR(primary_poc, STRPOS(primary_poc, ' ')+1) AS last_name
FROM accounts;

/*Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.*/
SELECT
	name AS sales_rep,
	LEFT(name, POSITION(' ' IN name)-1) AS first_name,
	SUBSTR(name, POSITION(' ' IN name)+1) AS last_name
FROM sales_reps;

/*Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/
SELECT
	name AS account,
	primary_poc,
	CONCAT(LOWER(LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)), '.', LOWER(SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1)), '@', SUBSTR(website, 5)) AS email
FROM accounts;

SELECT
	name AS account,
	primary_poc,
	CONCAT(LOWER(LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1)), '.', LOWER(SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1)), '@', REPLACE(LOWER(name), ' ', ''), '.com') AS email
FROM accounts;

/*We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.*/
SELECT
	name,
	primary_poc,
	LOWER(LEFT(primary_poc, 1))
	|| LOWER(SUBSTR(primary_poc, STRPOS(primary_poc, ' ') - 1, 1))
	|| LOWER(SUBSTR(primary_poc, STRPOS(primary_poc, ' ') + 1, 1))
	|| LOWER(RIGHT(primary_poc, 1))
	|| STRPOS(primary_poc, ' ') - 1
	|| LENGTH(primary_poc) - STRPOS(primary_poc, ' ')
	|| UPPER(REPLACE(name, ' ', '')) AS password
FROM accounts;

/*A different database is used to convert an unformatted date into timestamp format.*/
WITH t1 AS(
	SELECT
		date,
		LEFT(date, 2) AS month,
		SUBSTR(date, 4, 2) AS day,
		SUBSTR(date, 7, 4) AS year
	FROM sf_crime_data
	)
SELECT
	CAST(CONCAT(year, '-', month, '-', day) AS DATE) AS formatted_date
FROM t1;

/*filling zeros instead of NULL values*/

SELECT
	a.id,
	a.name,
	a.website,
	a.lat,
	a.long,
	a.primary_poc,
	a.sales_rep_id,
	o.id AS ord_id,
	COALESCE(o.account_id, a.id) AS account_id,
	o.occurred_at,
	COALESCE(o.standard_qty, 0) AS standard_qty,
	COALESCE(o.gloss_qty, 0) AS gloss_qty,
	COALESCE(o.poster_qty, 0) AS poster_qty,
	COALESCE(o.total, 0) AS total,
	COALESCE(o.standard_amt_usd, 0) AS standard_amt_usd,
	COALESCE(o.gloss_amt_usd, 0) AS gloss_amt_usd,
	COALESCE(o.poster_amt_usd, 0) AS poster_amt_usd,
	COALESCE(o.total_amt_usd, 0) AS total_amt_usd
FROM accounts AS a
LEFT JOIN orders AS o
ON a.id = o.account_id
WHERE o.* IS NULL;