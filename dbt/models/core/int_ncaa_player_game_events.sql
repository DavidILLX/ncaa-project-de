{{ 
    config(materialized='view') 
}}

with player_event_base as (
    select *
    from {{ ref('stg_ncaa_player_play_by_play') }}
)

, player_event_aggregation as (
    select
        play_id,
        game_id,
        player_id,
        player_name,
        season,
        team_id,
        team,
        opponents_id,
        opponents,
        event,
        type_of_event,
        event_description,
        CONCAT(event_coordinates_x,', ' , event_coordinates_y) as event_coordinates,
        event_coordinates_x,
        event_coordinates_y,
        event_timestamp,
        game_clock
        
    from player_event_base
)

select
    play_id,
    player_id,
    player_name,
    season,
    team,
    team_id,
    opponents_id,
    opponents,
    event,
    type_of_event,
    event_description,
    event_coordinates,
    event_coordinates_x,
    event_coordinates_y,
    event_timestamp,
    game_clock

from player_event_aggregation
where player_id is not null