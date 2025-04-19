{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_player_game_events') }}
    where play_id is not null
)

, order_events as (
    select *,
        row_number() over(partition by play_id order by event_timestamp, game_clock) as event_order
    from base
)

select 
    play_id,
    player_name,
    season,
    team,
    opponents,
    event,
    type_of_event,
    event_description,
    event_coordinates,
    event_timestamp,
    game_clock,
    event_order,

from order_events
order by event_order