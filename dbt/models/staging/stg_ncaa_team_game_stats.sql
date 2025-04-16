{{
    config(
        materialized='view'
    )
}}

with team_game_stats as 
(
  select scheduled_date, season, venue_state, venue_name, name, market, alias, conf_name, opp_name, opp_market, opp_alias, win, lead_changes, tied,
  field_goals_made, field_goals_att, field_goals_pct, two_points_made, two_points_att, two_points_pct, three_points_made, three_points_att, three_points_pct,
  free_throws_made, free_throws_att, free_throws_pct, rebounds, offensive_rebounds, defensive_rebounds, assists, turnovers, steals, blocks, points, opp_points_game, opp_minutes,
  opp_field_goals_made, opp_field_goals_att, opp_field_goals_pct, opp_three_points_made, opp_three_points_att, opp_three_points_pct, opp_two_points_made, opp_two_points_att, opp_two_points_pct,
  opp_blocked_att, opp_free_throws_made, opp_free_throws_att, opp_free_throws_pct, opp_offensive_rebounds, opp_defensive_rebounds, opp_rebounds, opp_assists, opp_turnovers, opp_steals, opp_blocks,
  opp_assists_turnover_ratio, opp_points, opp_fast_break_pts, opp_second_chance_pts, opp_team_turnovers, opp_points_off_turnover,
    row_number() over(partition by scheduled_date) as rn
  from {{ source('staging','ncaa_team_game_stats') }}
  where player_id is not null 
)

select
    -- Identification
    {{dbt_utils.generate_surrogate_key(['team_id', 'opp_id', 'venue_id', 'game_id'])}} as played_game_id,
    {{dbt.safe_cast("opp_id", api.Column.translate_type('string'))}},
    {{dbt.safe_cast("game_id", api.Column.translate_type('string'))}},
    {{dbt.safe_cast("team_id", api.Column.translate_type('string'))}},

    scheduled_date,
    season,
    venue_state,
    venue_name,
    name as team_name,
    market as team_state,
    alias as team_alias,
    conf_name as conference_name,
    opp_name as opponents_team_name,
    opp_market as opponents_state,
    opp_alias as opponents_alias,
    win as team_win,
    lead_changes,
    tied as tied_game,
    field_goals_made,
    field_goals_att as field_goals_attempted,
    field_goals_pct as field_goals_percentage,
    two_points_made,
    two_points_att as two_points_attempted,
    two_points_pct as two_points_percentage,
    three_points_made,
    three_points_att as three_points_attempted,
    three_points_pct as three_points_percentage,
    free_throws_made,
    free_throws_att as free_throws_attempted,
    free_throws_pct as free_throws_percentage,
    rebounds as team_rebounds,
    offensive_rebounds as team_offensive_rebounds,
    defensive_rebounds as team_defensive_rebounds,
    assists as team_assists,
    turnovers as team_turnovers,
    steals as team_steals,
    blocks as team_blocks,
    points as team_points,
    opp_points_game as opponents_points_game,
    opp_minutes as opponents_minutes,
    opp_field_goals_made as opponents_field_goals_made,
    opp_field_goals_att as opponents_field_goals_attempted,
    opp_field_goals_pct as opponents_field_goals_percentage,
    opp_three_points_made as opponents_three_points_made,
    opp_three_points_att as opponents_three_points_attempted,
    opp_three_points_pct as opponents_three_points_percentage,
    opp_two_points_made as opponents_two_points_made,
    opp_two_points_att as opponents_two_points_attempted,
    opp_two_points_pct as opponents_two_points_percentage,
    opp_blocked_att as opponents_blocked_attempted,
    opp_free_throws_made as opponents_free_throws_made,
    opp_free_throws_att as opponents_free_throws_attempted,
    opp_free_throws_pct as opponents_free_throws_percentage,
    opp_offensive_rebounds as opponents_offensive_rebounds,
    opp_defensive_rebounds as opponents_defensive_rebounds,
    opp_rebounds as opponents_rebounds,
    opp_assists as opponents_assists,
    opp_turnovers as opponents_turnovers,
    opp_steals as opponents_steals,
    opp_blocks as opponents_blocks,
    opp_assists_turnover_ratio as opponents_assists_turnover_ratio,
    opp_points as opponents_points,
    opp_fast_break_pts as opponents_fast_break_points,
    opp_second_chance_pts as opponents_second_chance_points,
    opp_team_turnovers as opponents_team_turnovers,
    opp_points_off_turnover as opponents_points_off_turnover,
    
from ncaa_dataset.ncaa_team_game_stats,
where rn = 1

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}