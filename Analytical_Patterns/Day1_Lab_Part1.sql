-- MASTERING GROWTH ACCOUNT AND RETENTION ANALYSIS

-- CREATE TABLE users_growth_accounting (
-- 	user_id TEXT,
-- 	first_active_date DATE,
-- 	last_active_date DATE,
-- 	daily_active_date DATE,
-- 	daily_active_state TEXT,
-- 	weekly_active_state TEXT,
-- 	dates_active DATE[],
-- 	date DATE,
-- 	PRIMARY KEY(user_id, date))

-- DROP TABLE  users_growth_accounting
INSERT INTO users_growth_accounting
WITH yesterday AS (
	SELECT * FROM users_growth_accounting
	WHERE date = DATE('2023-02-28') -- we assume everyone that is user on first of march is New
), -- then we should add date that we want in our table

	today AS (
		SELECT
		CAST(user_id AS TEXT) as user_id,
		DATE_TRUNC('day', event_time::timestamp) as today_date,
		COUNT(1)
		FROM events
		WHERE DATE_TRUNC('day', event_time::timestamp) = DATE('2023-02-28')
		GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
	)

	SELECT
	 	COALESCE(t.user_id, y.user_id) as user_id,
		COALESCE(y.first_active_date, t.today_date) as first_active_date,
		COALESCE(t.today_date, y.last_active_date) as last_active_date,
		CASE
			WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'
			WHEN y.last_active_date = t.today_date - INTERVAL '1 day' THEN 'Retained'
			WHEN y.last_active_date < t.today_date - INTERVAL '1 day' THEN 'Resurrected'
			WHEN t.today_date IS NULL AND y.last_active_date = y.date THEN 'Churned'
			ELSE 'Stale' END as daily_active_state,
		CASE
			WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'
			WHEN y.last_active_date < t.today_date - INTERVAL '7 day' THEN 'Resurrected'
			WHEN y.last_active_date >= y.date - INTERVAL '7 day' THEN 'Retained'
			WHEN t.today_date IS NULL AND y.last_active_date = y.date - INTERVAL '7 day' THEN 'Churned'
			ELSE 'Stale' END as weekly_active_state,
		COALESCE(y.dates_active,
			ARRAY[]::DATE[]) ||
			CASE WHEN
				t.user_id IS NOT NULL
				THEN ARRAY[t.today_date]
				ELSE ARRAY[]::DATE[]
				END AS date_list,
		COALESCE(t.today_date, y.date + INTERVAL '1 day') as date
		FROM today t
		FULL OUTER JOIN yesterday y
		ON t.user_id = y.user_id

SELECT date, daily_active_state, COUNT(1) FROM users_growth_accounting
GROUP BY date, daily_active_state;

SELECT
	extract(dow FROM first_active_date) as dow,
	date - first_active_date AS days_since_first_active,
	COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) AS numbers_active,
	COUNT(1),
	CAST(COUNT(CASE WHEN daily_active_state IN ('Retained','Resurrected','New') THEN 1 END) AS REAL)/COUNT(1) as pct_active
	FROM users_growth_accounting
	GROUP BY extract(dow FROM first_active_date) as dow, date - first_active_date; -- we can add another dimension to track how the churn of our users on site goes for example day of week etc

