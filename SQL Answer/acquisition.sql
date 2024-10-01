-- 1. How much total impression, reach, frequency generated per campaign
WITH campaign_user AS (
	SELECT mc.campaign_name , ae.id, ae.email, ae.is_clicked,
		CASE
			WHEN ae.email IS NOT NULL THEN ae.email
			ELSE CONCAT(ae.id, ae.timestamp)
		END pseudo_id
	FROM marketing_campaign mc 
	JOIN ads_exposure ae 
	ON mc.campaign_name = mc.campaign_name 
),
frequency_per_user_campaign AS (
	SELECT pseudo_id, campaign_name, COUNT(id) frequency
	FROM campaign_user
	GROUP BY pseudo_id, campaign_name
)
SELECT campaign_name, COUNT(DISTINCT pseudo_id) reach, AVG(frequency) avg_frequency
FROM frequency_per_user_campaign
GROUP BY 1;


-- 2. How much Return on Ads Spending per source
WITH last_campaign_see AS (
	SELECT ae.email,campaign_name, timestamp, ROW_NUMBER() OVER(PARTITION BY email ORDER BY timestamp DESC) rn
	FROM ads_exposure ae
),
detail_ads_expose AS (
	SELECT r.email, ls.campaign_name, ls.timestamp, ls.rn
	FROM registration r 
	LEFT JOIN last_campaign_see ls
	ON ls.email = r.email
	AND r.timestamp BETWEEN r.timestamp AND r.timestamp + INTERVAL '30 days'
	WHERE rn = 1
),
count_regist_from_campaign AS (
SELECT dae.campaign_name, COUNT(dae.email) count_regist
FROM detail_ads_expose dae
GROUP BY 1
),
campaign_metrics AS (
	SELECT mc.campaign_name, split_part(mc.campaign_name, '-', 1) lead_source, cr.count_regist, mc.spend, cr.count_regist * 5 / mc.spend * 100 roas
	FROM count_regist_from_campaign cr
	RIGHT JOIN marketing_campaign mc 
	ON mc.campaign_name  = cr.campaign_name
)
SELECT lead_source, SUM(count_regist), SUM(count_regist) * 5 / SUM(spend) roas_total, AVG(roas)
FROM campaign_metrics
GROUP BY 1;


-- 3. Which source most generate user sign up
WITH last_campaign_see AS (
	SELECT ae.email,campaign_name, timestamp, ROW_NUMBER() OVER(PARTITION BY email ORDER BY timestamp DESC) rn
	FROM ads_exposure ae
),
detail_ads_expose AS (
	SELECT r.email, ls.campaign_name, ls.timestamp, ls.rn
	FROM registration r 
	LEFT JOIN last_campaign_see ls
	ON ls.email = r.email
	AND r.timestamp BETWEEN r.timestamp AND r.timestamp + INTERVAL '30 days'
	WHERE rn = 1
),
count_regist_from_campaign AS (
SELECT dae.campaign_name, COUNT(dae.email) count_regist
FROM detail_ads_expose dae
GROUP BY 1
),
campaign_metrics AS (
	SELECT mc.campaign_name, split_part(mc.campaign_name, '-', 1) lead_source, cr.count_regist,
	FROM count_regist_from_campaign cr
	RIGHT JOIN marketing_campaign mc 
	ON mc.campaign_name  = cr.campaign_name
)
SELECT lead_source, SUM(count_regist)
FROM campaign_metrics
GROUP BY 1;