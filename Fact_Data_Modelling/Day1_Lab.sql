INSERT INTO fct_game_details (
    dim_game_date,
    dim_season,
    dim_team_id,
    dim_is_playing_at_home,
    dim_player_id,
    dim_player_name,
    dim_start_position,
    dim_did_not_play,
    dim_did_not_dress,
    dim_not_with_team,
    m_minutes,
    m_fgm,
    m_fga,
    m_fg3m,
    m_fg3a,
    m_ftm,
    m_fta,
    m_oreb,
    m_dreb,
    m_reb,
    m_ast,
    m_stl,
    m_turnovers,
    m_pf,
    m_pts,
    m_plus_minus
)
WITH deduped AS (
    SELECT g.game_date_est,
        g.season,
        g.home_team_id,
        gd.*,
        ROW_NUMBER() OVER(PARTITION BY gd.game_id, team_id, player_id) as row_num
    FROM game_details gd
    JOIN games g ON gd.game_id = g.game_id
)
SELECT
    game_date_est,
    season,
    team_id,
    (team_id = home_team_id),
    player_id,
    player_name,
    start_position,
    (COALESCE(POSITION('DNP' IN comment),0) > 0),
    (COALESCE(POSITION('DND' IN comment),0) > 0),
    (COALESCE(POSITION('NWT' IN comment),0) > 0),
    CAST(SPLIT_PART(min,':',1) AS REAL) + CAST(SPLIT_PART(min, ':',2) AS REAL),
    fgm,
    fga,
    fg3m,
    fg3a,
    ftm,
    fta,
    oreb,
    dreb,
    reb,
    ast,
    stl,
    "TO",
    pf,
    pts,
    plus_minus
FROM deduped
WHERE row_num = 1;
--DROP TABLE fct_game_details
--SELECT * FROM fct_game_details

SELECT dim_player_name,
	COUNT(1) AS num_games,
	COUNT(CASE WHEN dim_not_with_team THEN 1 END) AS bailed_num,
	CAST(COUNT(CASE WHEN dim_not_with_team THEN 1 END) AS REAL)/COUNT(1)
FROM fct_game_details
GROUP BY 1
ORDER BY 4 DESC
