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

, dim_teams as (
    select *
    from {{ ref('dim_teams')}}
)

select 
    b.play_id,
    p.player_id,
    p.player_full_name,
    p.player_position,
    b.season,

    -- Home team
    b.team_id,
    t.team_name,
  
    -- Opponents team
    o.team_id as opponents_id,
    o.team_name as opponents,

    b.event,
    b.type_of_event,
    b.event_description,
    b.event_coordinates,
    b.event_coordinates_x,
    b.event_coordinates_y,
    b.event_timestamp,
    b.game_clock,
    b.event_order

from base_events b
left join dim_player p on b.player_id = p.player_id
left join dim_teams t on b.team_id = t.team_id
left join dim_teams o on b.opponents_id = o.team_id
order by play_id, event_order, event_timestamp