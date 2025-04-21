{{
    config(
        materialized='view'
    )
}}

with player_game_stats as 
(
  select player_id, game_id, team_id, season, full_name, abbr_name, height, weight, birthplace_state, birthplace_country, team_name, team_market,
  played, starter, minutes_int64, field_goals_made, field_goals_att, field_goals_pct, two_points_made, 
  two_points_att, two_points_pct, three_points_made, three_points_att, three_points_pct, 
  free_throws_made, free_throws_att, free_throws_pct, offensive_rebounds, defensive_rebounds, 
  assists, turnovers, steals, blocks, personal_fouls, tech_fouls, flagrant_fouls, points
  from {{ source('staging','ncaa_player_game_stats') }}
  where player_id is not null 
)

select
    -- Identification
    {{dbt_utils.generate_surrogate_key(['player_id', 'team_id', 'game_id', 'scheduled_date'])}} as player_team_id,
    {{dbt.safe_cast("player_id", api.Column.translate_type('string'))}} as player_id,
    {{dbt.safe_cast("game_id", api.Column.translate_type('string'))}} as game_id,
    {{dbt.safe_cast("team_id", api.Column.translate_type('string'))}} as team_id,

    -- Get only the date from TIMESTAMP
    date(scheduled_date) as scheduled_date,
    season,

    full_name as player_full_name,
    abbr_name as abbrevated_name,
    height,
    weight,
    birthplace_state,
    birthplace_country,
    team_name as team,
    team_market as team_state,
    played as number_of_games_played,
    starter as number_of_games_as_starter,
    minutes_int64 as minutes_played,

    -- Stats concerning performance
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
    free_throws_att as free_throws_attemtep,
    free_throws_pct as free_throws_percentage,
    offensive_rebounds,
    defensive_rebounds,
    assists,
    turnovers,
    steals,
    blocks,
    personal_fouls,
    tech_fouls,
    flagrant_fouls,
    (personal_fouls + tech_fouls + flagrant_fouls) as fouls,
    points,

    {{get_player_position('position')}} as player_position,
    {{get_player_status('status')}} as player_status
    
from ncaa_dataset.ncaa_player_game_stats

