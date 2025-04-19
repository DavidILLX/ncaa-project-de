{{ 
    config(materialized='table') 
}}

select distinct
    team_id,
    team_name,
    team_alias,
    team_state,
    conference_name,
from {{ ref('stg_ncaa_team_game_stats') }}