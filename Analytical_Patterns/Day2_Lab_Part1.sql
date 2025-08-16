-- AGGREGATION BASED PATTERN
--CREATE TABLE web_events_dashboard AS
WITH combined AS (
SELECT *,
	CASE
		WHEN referrer LIKE '%zachwilson%' THEN 'On Site'
		WHEN referrer LIKE '%eczachly%' THEN 'On Site'
		WHEN referrer LIKE '%dataengineer.io%' THEN 'On Site'
		WHEN referrer LIKE '%t.co%' THEN 'Twitter'
		WHEN referrer LIKE '%linkedin' THEN 'Linkedin'
		WHEN referrer LIKE '%instagram%' THEN 'Instagram'
		WHEN referrer IS NULL THEN 'Direct' ELSE 'Other'
		END as referrer_mapped

	FROM events e JOIN devices d
	ON e.device_id = d.device_id

)
SELECT COALESCE(referrer_mapped,'Overall') as referrer,
		COALESCE(browser_type, 'Overall') as browser_type,
		COALESCE(os_type, 'Overall') as os_type,
		COUNT(1),
		COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
		COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
		COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,
		CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL )/COUNT(1) AS pct_visits_signup

FROM combined
GROUP BY ROLLUP((referrer_mapped, browser_type, os_type)) -- these group by and the one below are the same - rollup better for hierachical data
-- --GROUP BY GROUPING SETS
-- 	((referrer_mapped, browser_type, os_type),
-- 	(browser_type),
-- 	(os_type),
-- 	(referrer_mapped),())
HAVING COUNT(1) > 100
ORDER BY COUNT(1)
