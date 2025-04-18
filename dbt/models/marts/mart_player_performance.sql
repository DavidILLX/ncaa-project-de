{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_player_season_stats') }}
    where player_status <> 'RET'
)

, performance_evaluation as (
    select 
        player_full_name,
        physical_stats,
        player_position,
        player_status,
        team_name,
        number_of_games_played,
        number_of_games_as_starter,
        minutes_played,
        field_goals_made,
        field_goals_percentage,
        two_points_made,
        two_points_percentage,
        three_points_made,
        three_points_percentage,
        free_throws_made,
        free_throws_percentage,
        offensive_rebounds,
        defensive_rebounds,
        assists,
        turnovers,
        steals,
        blocks,
        personal_fouls,
        tech_fouls,
        flagrant_fouls,
        points,
        (points * 0.7 + offensive_rebounds * 0.5 + defensive_rebounds * 0.5 + 
        assists * 0.7 + steals * 0.4 + blocks * 0.5 - turnovers * 0.5) as performance_score,
        dense_rank() over(partition by team_name order by performance_score) as player_rank
    from base
)

, performance as (
    select *,
        case
            when performance_score > 0.7 then true else false
        end as draft_prospect
    from performance_evaluation
)

select
    player_full_name,
    physical_stats,
    player_position,
    player_status,
    team_name,
    number_of_games_played,
    number_of_games_as_starter,
    minutes_played,
    field_goals_made,
    field_goals_percentage,
    two_points_made,
    two_points_percentage,
    three_points_made,
    three_points_percentage,
    free_throws_made,
    free_throws_percentage,
    offensive_rebounds,
    defensive_rebounds,
    assists,
    turnovers,
    steals,
    blocks,
    personal_fouls,
    tech_fouls,
    flagrant_fouls,
    points,
    player_rank,
    performance_score,
    draft_prospect,
from performance