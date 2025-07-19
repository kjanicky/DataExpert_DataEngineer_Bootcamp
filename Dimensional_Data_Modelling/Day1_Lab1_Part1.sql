--SELECT * FROM player_seasons;

--CREATE TYPE season_stats AS ( 
						--season INTEGER,
						--gp INTEGER,
						--pts REAL,
						--reb REAL,
						--ast REAL)

-- CREATE TABLE players(
-- 	player_name TEXT,
-- 	height TEXT,
-- 	college TEXT,
-- 	country TEXT,
-- 	draft_year TEXT,
-- 	draft_round TEXT,
-- 	draft_number TEXT,
-- 	season_stats season_stats[],
-- 	current_season INTEGER,
-- 	PRIMARY KEY(player_name, current_season)
-- )
INSERT INTO players
WITH yesterday AS (
	SELECT * FROM players
	WHERE current_season = 2000
),
	today AS (
		SELECT* FROM player_seasons
		WHERE season = 2001
	)
SELECT  
	COALESCE(t.player_name, y.player_name) AS player_name,
	COALESCE(t.height, y.height) AS height,
	COALESCE(t.college, y.college) AS college,
	COALESCE(t.country , y.country ) AS country ,	
	COALESCE(t.draft_year, y.draft_year) AS draft_year,
	COALESCE(t.draft_round, y.draft_round) AS draft_round,
	COALESCE(t.draft_number , y.draft_number ) AS draft_number, --handling the OUTER JOIN for seasons
	CASE WHEN y.season_stats IS NULL --contructin array of values for a season
		THEN ARRAY[ROW(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats]
		WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW( --
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_stats]
		ELSE y.season_stats -- case when this is last season of a player carrying history data forward
		END as season_stats,
		COALESCE(t.season, y.current_season + 1) as current_season --handling current season for first season
		
FROM today t
FULL OUTER JOIN yesterday y ON t.player_name = y.player_name

-- WITH unnested AS 
-- (SELECT  player_name,
-- UNNEST(season_stats)::season_stats as season_stats --flattening the table to its beginning - back to old schema
-- FROM players 
-- WHERE current_season = 2001 AND player_name = 'Michael Jordan')

-- SELECT player_name,
-- (season_stats::season_stats).*
-- FROM unnested
