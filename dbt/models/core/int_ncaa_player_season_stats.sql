{{ 
    config(materialized='view') 
}}

with player_stats_base as (
    select *
    from {{ ref('stg_ncaa_player_game_stats') }}
)

, player_stats_aggregation as (
    select
        player_team_id,
        game_id,
        player_full_name
        CONCAT('H: ',CAST(height as CHAR) , ', W:', CAST(weight as CHAR)) as physical_stats,
        player_position,
        player_status,
        birth_state,
        birth_country,
        team,
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
        points

    from player_stats_base,
)

select
    player_team_id,
    game_id,
    player_full_name,
    physical_stats,
    player_position,
    player_status,
    birth_state,
    birth_country,
    team,
    number_of_games_played,
    number_of_games_as_starter,
    minues_played,
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

from player_stats_aggregation