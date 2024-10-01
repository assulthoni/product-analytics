-- 1. Conversion rate from landing page visitor to paid and show the funnel
-- definition :
-- - landing page is "main" path
-- - view page purchase is "subscribe"
-- - actual pay on table purchase
WITH landing_page AS (
	SELECT user_id, "path", timestamp
	FROM website_event we 
	WHERE "path" = 'main'
),
subs_page_and_lp AS (
	SELECT
		lp."path" subs_path,
		lp.timestamp lp_page_time,
		lp.user_id lp_uid,
		we."path",
		we.timestamp subs_page_time,
		we.user_id subs_uid		
	FROM website_event we 
	RIGHT JOIN landing_page lp
		ON we.user_id = lp.user_id
		AND we.timestamp >= lp.timestamp
        AND DATE(we.timestamp) = DATE(lp.timestamp)
		AND we."path" = 'subscribe'
),
purchase AS (
	SELECT p.user_id purchase_uid, p.timestamp purchase_time, sp.*
	FROM purchase p
	RIGHT JOIN subs_page_and_lp sp
		ON p.user_id = sp.lp_uid
		AND p.timestamp >= sp.subs_page_time
        AND DATE(p.timestamp) = DATE(sp.subs_page_time)
)
SELECT COUNT(lp_uid), COUNT(subs_uid), COUNT(purchase_uid)
FROM purchase;


-- How much average time taken for certain user to convert from landing page to sign up
WITH landing_page AS (
	SELECT user_id, "path", timestamp lp_time
	FROM website_event we 
	WHERE "path" = 'main'
),
registration AS (
	SELECT p.user_id purchase_uid, p.timestamp purchase_time, lp.*
	FROM purchase p
	RIGHT JOIN landing_page lp
		ON p.user_id = lp.user_id
		AND p.timestamp >= lp.lp_time
        AND DATE(p.timestamp) = DATE(lp.lp_time)
)
SELECT AVG(purchase_time - lp_time)
FROM registration;

