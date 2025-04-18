{{ 
    config(materialized='view') 
}}

with player_event_base as (
    select *
    from {{ ref('stg_ncaa_player_play_by_play') }}
)

, player_event_aggregation as (
    select
        game_id,
        player_id,
        player_name,
        season,
        team,
        opponents,
        event,
        event_type,
        event_description,
        CONCAT(event_coordinates_x,', ' , event_coord_y) as event_coordinates,
        event_timestamp,
        
    from player_event_base
)

select
    {{ dbt_utils.generate_surrogate_key(['player_id', 'season']) }} as player_season_id,
    player_id,
    player_name,
    season,
    team,
    opponents,
    event,
    event_type,
    event_description,
    event_coordinates,
    event_timestamp,
    game_clock,

from player_event_aggregation
where play_id is not null