{{ 
    config(materialized='table') 
}}

select distinct
    player_id,
    player_full_name,
    abbrevated_name,
    height,
    weight,
    player_position,
    player_status,
    birth_state,
    birth_country,
    player_status,
    team_id,
    team_name

from {{ ref('stg_ncaa_player_game_stats') }}