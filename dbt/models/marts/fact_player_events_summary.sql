{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_player_game_events') }}
    where play_id is not null
)

, base_events as (
    select *,
        row_number() over(partition by play_id order by event_timestamp, game_clock) as event_order
    from base
)

, dim_player as (
    select *
    from {{ ref('dim_player')}}
)

select 
    b.play_id,
    p.player_id,
    p.player_full_name,
    p.player_position,
    b.season,
    b.team,
    b.opponents,
    b.event,
    b.type_of_event,
    b.event_description,
    b.event_coordinates,
    b.event_timestamp,
    b.game_clock,
    b.event_order

from base_events b
left join dim_player p on b.player_id = p.player_id
order by play_id, event_order