-- QUERY TO FIND a USER HISTORY ON A PAGE IN A SESSION
WITH combined AS (
SELECT *,
	CASE
		WHEN referrer LIKE '%zachwilson%' THEN 'On Site'
		WHEN referrer LIKE '%eczachly%' THEN 'On Site'
		WHEN referrer LIKE '%dataengineer.io%' THEN 'On Site'
		WHEN referrer LIKE '%x.co%' THEN 'Twitter'
		WHEN referrer LIKE '%linkedin' THEN 'Linkedin'
		WHEN referrer LIKE '%instagram%' THEN 'Instagram'
		WHEN referrer IS NULL THEN 'Direct' ELSE 'Other'
		END as referrer_mapped

	FROM events e JOIN devices d
	ON e.device_id = d.device_id

), aggregated AS (
SELECT c1.user_id, c1.url as to_url, c2.url as from_url, MIN(c1.event_time - c2.event_time) as duration
FROM combined c1 JOIN combined c2
	ON c1.user_id = c2.user_id
	AND DATE(c1.event_time) = DATE(c2.event_time)
	AND c1.event_time > c2.event_time
GROUP BY c1.user_id, c1.url, c2.url
)

SELECT
	to_url,
	from_url,
	COUNT(1) as number_of_users,
	MIN(duration) as min_duration,
	MAX(duration) as max_duration,
	AVG(duration) as avg_duration
FROM aggregated
GROUP BY to_url, from_url