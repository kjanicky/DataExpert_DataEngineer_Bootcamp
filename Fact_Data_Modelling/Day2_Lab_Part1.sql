-- DROP TABLE users_cumulated;
-- CREATE TABLE users_cumulated (
-- 	user_id TEXT, --the list of dates in the past where the user was active
-- 	dates_active DATE[],
-- 	date DATE, -- current data for the user
-- 	PRIMARY KEY(user_id, date)
-- )

INSERT INTO users_cumulated --doing inserts for the dates we want(from 1st to 31st) have to change it in a timestamp
WITH yesterday AS (
    SELECT *
    FROM users_cumulated
    WHERE date = DATE('2023-01-30')
),
today AS (
    SELECT
        CAST(user_id AS TEXT),
        DATE(CAST(event_time AS TIMESTAMP)) AS date_active
    FROM events
    WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31')
      AND user_id IS NOT NULL
    GROUP BY user_id, DATE(CAST(event_time AS TIMESTAMP))
)
SELECT
	COALESCE(t.user_id, y.user_id) AS user_id,
	CASE
			WHEN y.dates_active IS NULL THEN ARRAY[t.date_active]
			WHEN t.date_active IS NULL THEN y.dates_active
			ELSE ARRAY[t.date_active] || y.dates_active
			END as dates_active,
	COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date
	FROM today t
	FULL OUTER JOIN yesterday y
    	ON t.user_id = y.user_id;