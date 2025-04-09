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
SELECT utm_content, COUNT(DISTINCT(website_session_id)) AS sessions
FROM website_sessions
WHERE website_session_id 
		BETWEEN 1000 AND 2000
GROUP BY utm_content -- or 1
ORDER BY sessions DESC; -- or 2


-- To bring in the orders table to take a look at the orders generated from each ads
-- I'm making use of alias for each table name also so the column names on the syntax is not too large when identifying them or specifying them
SELECT WS.utm_content, 
		COUNT(DISTINCT(WS.website_session_id)) AS sessions,
        COUNT(DISTINCT(O.order_id)) AS orders,
        COUNT(DISTINCT(O.order_id))/COUNT(DISTINCT(WS.website_session_id))*100 AS conversion_rate -- Session to Order conversion rate
FROM website_sessions AS WS
	LEFT JOIN orders as O
		ON WS.website_session_id = O.website_session_id
WHERE WS.website_session_id 
		BETWEEN 1000 AND 2000
GROUP BY utm_content -- or 1
ORDER BY sessions DESC; -- or 2