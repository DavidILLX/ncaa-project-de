{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_team_game_stats') }}
    where total_games > 30
)

, ranked as(
    select *,
    dense_rank() over(partition by season order by win_ratio) as team_rank
    from base
)

, classified as(
    select *,
        case
            when team_rank <= 15 then 'High'
            when team_rank > 15 then 'Medium' 
            else 'Low'
        end as performance_team
    from ranked
)

select  
    season,
    team_rank,
    performance_team,
    team_id, 
    team_name, 
    team_alias,
    total_games,
    win_ratio,
    total_points,
    total_field_goals,
    total_free_throws_made,
    total_assists,
    total_rebounds,
    total_defensive_rebounds,
    total_offensive_rebounds,
    total_blocks,
    total_steals,
    total_turnovers,
from classified
