{{ 
    config(materialized='view') 
}}

with tournament_base as (
    select *
    from {{ ref('stg_ncaa_historical_tournament_games') }}
)

, tournament_aggregation as (
    select
    tournament_game_id,
    game_date,
    season,
    round,
    win_team_id,
    CONCAT(winning_team_name,' ', winning_team_alias) as winning_team,
    winning_team_points,
    lose_team_id,
    CONCAT(losing_team_name,' ', losing_team_alias) as losing_team,
    losing_team_points,
    winning_team_points - losing_team_points as point_difference,

    from tournament_base
)

select
    tournament_game_id,
    game_date,
    season,
    round,
    win_team_id,
    winning_team,
    winning_team_points,
    lose_team_id,
    losing_team,
    losing_team_points,
    point_difference

from tournament_aggregation