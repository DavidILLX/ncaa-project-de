{{ 
    config(materialized='table') 
}}

select distinct
    player_id,
    player_full_name,
    abbrevated_name,
    height,
    weight,
    physical_stats,
    player_position,
    player_status,
    birthplace_state,
    birthplace_country,

from {{ ref('int_ncaa_player_season_stats') }}