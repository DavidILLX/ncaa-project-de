{{ 
    config(materialized='table') 
}}

with base as (
    select 
        player_id,
        game_id,
        team_id,
        points,
        assists,
        rebounds,
        steals,
        blocks,
        turnovers,
        fouls
    from {{ ref('stg_ncaa_player_game_stats') }}
    where player_status <> 'RET' -- Filter out retired players
)

, performance as (
    select
        player_id,
        game_id,
        team_id,
        sum(points) as total_points,
        sum(assists) as total_assists,
        sum(rebounds) as total_rebounds,
        sum(steals) as total_steals,
        sum(blocks) as total_blocks,
        sum(turnovers) as total_turnovers,
        sum(fouls) as total_fouls,
        count(*) as total_games
    from base
    group by player_id, game_id, team_id
)

select
    player_id,
    game_id,
    team_id,
    total_points,
    total_assists,
    total_rebounds,
    total_steals,
    total_blocks,
    total_turnovers,
    total_fouls,
    total_games
from performance