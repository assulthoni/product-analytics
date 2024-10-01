-- Average sesion length per day
WITH start_session_event AS (
	SELECT *, DATE(timestamp) date,
		CASE
	      WHEN LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) IS NULL THEN 1
    	  WHEN EXTRACT(DAY FROM timestamp) != EXTRACT(DAY FROM LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp)) THEN 1
	      WHEN EXTRACT(EPOCH FROM (timestamp - LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp))) > 1800 THEN 1
    	  ELSE 0 
	    END AS new_session
	FROM website_event
),
assign_session_id AS (
SELECT *, SUM(new_session) OVER (PARTITION BY user_id ORDER BY timestamp) sess_id
FROM start_session_event
),
session_length AS (
SELECT date, user_id, sess_id, MAX(timestamp) - MIN(timestamp) sess_length
FROM assign_session_id
GROUP BY 1,2,3
)
SELECT date, AVG(sess_length) avg_session_length, MIN(sess_length), MAX(sess_length)
FROM session_length
GROUP BY date;


-- How much average page visit per session
WITH start_session_event AS (
	SELECT *, DATE(timestamp) date,
		CASE
	      WHEN LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) IS NULL THEN 1
    	  WHEN EXTRACT(DAY FROM timestamp) != EXTRACT(DAY FROM LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp)) THEN 1
	      WHEN EXTRACT(EPOCH FROM (timestamp - LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp))) > 1800 THEN 1
    	  ELSE 0 
	    END AS new_session
	FROM website_event
),
assign_session_id AS (
SELECT *, SUM(new_session) OVER (PARTITION BY user_id ORDER BY timestamp) sess_id
FROM start_session_event
),
session_length AS (
SELECT date, user_id, sess_id, COUNT(CASE WHEN event_name = 'page_view' THEN "path" END) total_page, COUNT(DISTINCT CASE WHEN event_name = 'page_view' THEN "path" END) total_unique_page
FROM assign_session_id
GROUP BY 1,2,3
)
SELECT date, AVG(total_page) avg_page, AVG(total_unique_page) total_unique_page
FROM session_length
GROUP BY date;


-- How much stickiness rate per day
-- stickiness : DAU / MAU
WITH dau AS (
	SELECT DATE(timestamp) date, COUNT(DISTINCT user_id) dau_number
	FROM website_event we 
	GROUP BY 1
),
mau AS (
	SELECT DATE_TRUNC('month',timestamp) m, COUNT(DISTINCT user_id) mau_number
	FROM website_event we 
	GROUP BY 1
),
stickiness AS (
	SELECT *, dau_number::float / mau_number::float stickiness
	FROM dau
	JOIN mau
		ON DATE_TRUNC('month',dau.date) = mau.m
)
SELECT *
FROM stickiness
ORDER BY date;