-- To select which schema or database to use
USE mavenfuzzyfactory;

-- To select all in website sessions
SELECT *
FROM website_sessions;

-- To display the log of the pages viewed by a user when they were on the ecommerce website in a session
SELECT *
FROM website_pageviews
WHERE website_session_id = 1059;

-- To view the revenue generated by a user per website session id
SELECT *
FROM orders
WHERE website_session_id = 1059;

-- To show all the utm sources and campaigns we have
SELECT DISTINCT
	utm_source,
	utm_campaign
FROM website_sessions;

-- My results keep showing a null value in a row so i wangt to permanently delete it.
DELETE 
FROM website_sessions
WHERE website_session_id IS NULL;

SELECT *
FROM website_sessions
WHERE website_session_id BETWEEN 1000 AND 5000;

-- utm_content is  used to store the name of a specific ad that is being run
-- count of website sessions to see which ads are driving the most sessions
-- We rename the distinct count of the website session id with an alias (sessions)
SELECT utm_content, COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE website_session_id 
		BETWEEN 1000 AND 2000
GROUP BY utm_content -- or 1
ORDER BY sessions DESC; -- or 2


-- To bring in the orders table to take a look at the orders generated from each ads
-- I'm making use of alias for each table name also so the column names on the syntax is not too large when identifying them or specifying them
SELECT WS.utm_content, 
		COUNT(DISTINCT WS.website_session_id) AS sessions,
        COUNT(DISTINCT O.order_id) AS orders,
        COUNT(DISTINCT O.order_id)/COUNT(DISTINCT WS.website_session_id)*100 AS conversion_rate -- Session to Order conversion rate
FROM website_sessions AS WS
	LEFT JOIN orders as O
		ON WS.website_session_id = O.website_session_id
WHERE WS.website_session_id 
		BETWEEN 1000 AND 2000
GROUP BY utm_content -- or 1
ORDER BY sessions DESC; -- or 2


-- To conversion_rate cleaner and easily readable, you can use a subquery instead
-- MySQL does not allow you to reuse aliases in the same SELECT clause (unlike some other databases)
SELECT ads,
		sessions,
        orders,
        orders/sessions*100 AS conversion_rate
FROM(
	SELECT WS.utm_content AS ads, 
			COUNT(DISTINCT WS.website_session_id) AS sessions,
			COUNT(DISTINCT O.order_id) AS orders
	FROM website_sessions AS WS
		LEFT JOIN orders as O
			ON WS.website_session_id = O.website_session_id
	WHERE WS.website_session_id 
			BETWEEN 1000 AND 2000
	GROUP BY utm_content -- or 1
	ORDER BY sessions DESC -- or 2
) AS sub
ORDER BY 2 DESC;

-- Volume of website sessions by utm source, campaign and referring domain up till April 12, 2012
SELECT utm_source AS sources,
		utm_campaign AS campaign,
        http_referer AS refer_domain,
        COUNT(DISTINCTwebsite_session_id) AS website_sessions
FROM website_sessions
WHERE DATE(created_at) < '2012-04-12'
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- Calculating converion rate from session to order on gsearch(source) nonbrand (campaign) from April 14, 2012 downward
SELECT COUNT(DISTINCT WS.website_session_id) AS sessions,
		COUNT(DISTINCT O.order_id) AS orders,
        COUNT(DISTINCT O.order_id)/COUNT(DISTINCT WS.website_session_id)*100 AS CVR
FROM website_sessions AS WS
	LEFT JOIN orders AS O
		ON WS.website_session_id = O.website_session_id
WHERE WS.created_at < '2012-04-14'
		AND WS.utm_source = 'gsearch'
        AND WS.utm_campaign = 'nonbrand';
        
-- Bid Optimization
-- Understsnding the value of various segments of paid traffic in order to optimize marketing budget
-- Working with grouped dates
SELECT website_session_id,
		created_at,
        MONTH(created_at),
        WEEK(created_at),
        YEAR(created_at)
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000; -- arbitary

SELECT YEAR(created_at) AS Year,
        WEEK(created_at) AS Wk,
        MIN(DATE(created_at)) AS min_date_start, 
        COUNT(DISTINCT website_session_id) AS session
FROM website_sessions
WHERE website_session_id 
	BETWEEN 100000 AND 115000 -- arbitary
GROUP BY 1,2;

-- Pivoting Data wth Count and Case
SELECT
	order_id AS id,
    primary_product_id AS prod_id,
    items_purchased AS items
FROM orders
WHERE order_id
	BETWEEN 31000 AND 32000;
    
-- To pivot the table result above;

SELECT primary_product_id,
		order_id,
        items_purchased,
		CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END AS 1_item,
		CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END AS 2_items
FROM orders
WHERE order_id
	BETWEEN 31000 AND 32000;
    
SELECT primary_product_id,
		order_id,
        items_purchased,
		COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS 1_item,
		COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS 2_items
FROM orders
WHERE order_id
	BETWEEN 31000 AND 32000
GROUP BY 1,2,3;

SELECT primary_product_id,
		COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS 1_item,
		COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS 2_items,
		COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_id
	BETWEEN 31000 AND 32000
GROUP BY 1;

-- Traffic Source Trending
SELECT 	YEAR(created_at) AS yr,
		WEEK(created_at) AS wk,
		MIN(DATE(created_at)) AS week_start_date,
		COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
		AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1,2;

SELECT 	MIN(DATE(created_at)) AS week_start_date,
		COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10'
		AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at),
		WEEK(created_at);

-- Traffic source bid optimization
SELECT
	device_type,
    sessions,
    orders,
    orders/sessions*100
FROM(
	SELECT WS.device_type AS device_type,
			COUNT(DISTINCT  WS.website_session_id) AS sessions,
			COUNT(DISTINCT O.order_id) AS orders
	FROM website_sessions AS WS
	LEFT JOIN orders AS O
			ON WS.website_session_id = O.website_session_id
	WHERE WS.created_at < '2012-05-11'
			AND WS.utm_source = 'gsearch'
			AND WS.utm_campaign = 'nonbrand'
	GROUP BY 1
) AS sub
GROUP BY 1;

SELECT MIN(DATE (WS.created_at)) AS week_start_date,
			COUNT(DISTINCT CASE WHEN WS.device_type ='desktop' THEN WS.website_session_id ELSE NULL END) AS dskt_sessions,
			COUNT(DISTINCT CASE WHEN WS.device_type = 'mobile' THEN WS.website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions AS WS
LEFT JOIN orders AS O
		ON WS.website_session_id = O.website_session_id
WHERE WS.created_at > '2012-04-15' 
		AND 
	  WS.created_at  < '2012-06-09'
		AND WS.utm_source = 'gsearch'
		AND WS.utm_campaign = 'nonbrand'
GROUP BY WEEK (DATE (WS.created_at));

-- Analyzing Top Website Content
CREATE TEMPORARY TABLE first_pg_view
SELECT website_session_id,
		MIN(website_pageview_id) AS min_pvid	
FROM website_pageviews
WHERE website_pageview_id <1000
GROUP BY 1;

SELECT *
FROM first_pg_view;

SELECT FP.website_session_id,
        WP.pageview_url
FROM first_pg_view AS FP
	LEFT JOIN website_pageviews AS WP
		ON FP.min_pvid = WP.website_pageview_id;
        
SELECT WP.pageview_url,
		COUNT(DISTINCT FP.website_session_id)
FROM first_pg_view AS FP
	LEFT JOIN website_pageviews AS WP
		ON FP.min_pvid = WP.website_pageview_id
GROUP BY 1;