{{ 
    config(materialized='table') 
}}

select distinct
    team_id,
    team_name,
    team_alias,
    team_state,
    conference_name,
    conference_alias,
    league_name,
    league_alias,
    division_name,
    division_alias

from {{ ref('int_ncaa_team_game_stats') }}