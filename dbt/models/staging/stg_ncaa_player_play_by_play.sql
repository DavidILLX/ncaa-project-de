{{
    config(
        materialized='view'
    )
}}

with play_by_play as 
(
  select player_id, game_id, team_id, points_scored, scheduled_date, player_full_name,
    team_name, shot_type, shot_made, attendance, game_clock, season, rebound_type,
    turnover_type, event_coord_x, event_coord_y, event_description, timestamp, type, event_type
  from {{ source('staging','ncaa_player_play_by_play') }}
  where game_id is not null 
)

select
    -- Identification
    {{dbt_utils.generate_surrogate_key(['player_id', 'game_id', 'team_id'])}} as play_id,
    {{dbt.safe_cast("player_id", api.Column.translate_type('string'))}} as player_id,
    {{dbt.safe_cast("game_id", api.Column.translate_type('string'))}} as game_id,
    {{dbt.safe_cast("team_id", api.Column.translate_type('string'))}} as team_id,

    -- Casting from FLOAT to INT
    cast(points_scored as integer) as points,

    -- Get only the date from TIMESTAMP
    date(scheduled_date) as scheduled_date,

    player_full_name as player_name,
    team_name as team,
    away_name as opponents,
    shot_type,
    attendance,
    shot_made,
    game_clock,
    season,
    rebound_type,
    turnover_type,
    event_coord_x as event_coordinates_x,
    event_coord_y as event_coordinates_y,
    event_description,
    timestamp as event_timestamp,

    -- Macros
    {{ get_event_type('event_type')}} as type_of_event,
    {{ get_event('type') }} as event
     

from ncaa_dataset.ncaa_player_play_by_play



    
