-- Create projected MRR in next 6 months
WITH raw_data AS (
SELECT
	p.id,
	s.user_id,
	start_date,
	end_date,
	amount
FROM "subscription" s
JOIN purchase p ON s.purchase_id = p.id
),
active_account AS (
	SELECT
		generate_series(
			DATE_TRUNC('month',start_date),
			DATE_TRUNC('month',end_date),
			INTERVAL '1 month') mt,
		COUNT(DISTINCT user_id) active
	FROM raw_data
	GROUP BY 1
),
rev_normalized AS (
SELECT
	id,
	user_id,
	DATE_TRUNC('month',start_date) start_month,
	DATE_TRUNC('month',end_date) end_month,
	amount,
	amount / NULLIF((EXTRACT(MONTH FROM DATE_TRUNC('month',end_date)) 
	- EXTRACT(MONTH FROM DATE_TRUNC('month',start_date)) + 1), 0) revenue
FROM raw_data
),
rev_monthly AS (
	SELECT generate_series(
			start_month,
			end_month,
			INTERVAL '1 month') mt,
			revenue,
			user_id
	FROM rev_normalized
),
arpu_month AS (
	SELECT mt, SUM(revenue) / COUNT(user_id) arpu
	FROM rev_monthly
	GROUP BY 1
)
SELECT COALESCE(active_account.mt, arpu_month.mt) m, arpu_month.arpu,active_account.active, active_account.active * arpu_month.arpu MRR
FROM active_account
FULL JOIN arpu_month ON arpu_month.mt = active_account.mt;


-- How much retention rate in Monthly basis
WITH raw_data AS (
SELECT
	s.user_id,
	start_date,
	end_date,
	LAG(start_date) OVER (PARTITION BY user_id ORDER BY start_date) last_init_subs
FROM "subscription" s
),
monthly_activity_user AS (
SELECT
	generate_series(
		DATE_TRUNC('month', start_date),
		DATE_TRUNC('month', end_date),
		INTERVAL '1 month'
	) mt,
	user_id,
	CASE
		WHEN last_init_subs IS NULL THEN 'new'
		WHEN DATE_PART('month', AGE(last_init_subs, start_date)) >3 THEN 'reactivated'
		WHEN DATE_PART('month', AGE(last_init_subs, start_date)) <=3 THEN 'retain'
	END status
FROM raw_data
),
monthly_stats AS (
SELECT
	mt,
	COUNT(user_id) end_user,
	COUNT(CASE WHEN status = 'new' THEN user_id END) new_user,
	COUNT(CASE WHEN status = 'retain' THEN user_id END) retain_user,
	COUNT(CASE WHEN status = 'reactivated' THEN user_id END) reactivated_user
FROM monthly_activity_user
GROUP BY mt
),
all_stats AS (
SELECT *, LAG(end_user) OVER (ORDER BY mt) beginning_user
FROM monthly_stats
)
SELECT *, (end_user::float - new_user::float) / beginning_user::float retention_rate
FROM all_stats;
