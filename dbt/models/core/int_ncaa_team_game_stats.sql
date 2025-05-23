{{ 
    config(materialized='view') 
}}

with base as (
    select *
    from {{ ref('stg_ncaa_team_game_stats') }}
)

, game_aggregation as (
    select
        game_id,
        team_id,
        team_name,
        team_alias,
        team_state,
        season,
        conference_name,
        conference_alias,
        league_name,
        league_alias,
        division_name,
        division_alias,
        opp_id,
        opponents_team_name,
        opponents_state,
        opponents_alias,

        count(*) as total_games,

        -- Calculating teams wins and losses
        sum(case when team_win = true then 1 else 0 end) as wins,
        sum(case when team_win = false then 1 else 0 end) as losses,

        -- Calculating basics statistics for team
        sum(team_points) as total_points,
        sum(field_goals_made) as total_field_goals,
        avg(field_goals_percentage) as avg_field_goals_percentage,
        avg(two_points_percentage) as avg_two_points_percentage,
        avg(three_points_percentage) as avg_three_points_percentage,
        sum(free_throws_made) as total_free_throws_made,
        avg(free_throws_percentage) as avg_free_throws_percentage,
        sum(team_assists) as total_assists,
        sum(team_rebounds) as total_rebounds,
        sum(team_defensive_rebounds) as total_defensive_rebounds,
        sum(team_offensive_rebounds) as total_offensive_rebounds,
        sum(team_steals) as total_steals,
        sum(team_blocks) as total_blocks,
        sum(team_turnovers) as total_turnovers,
        avg(team_points) as avg_points_per_game,
        avg(team_assists) as avg_assists_per_game

    from base
    group by game_id, team_id, team_name, team_alias, team_state, season, conference_name, conference_alias, league_name, league_alias, division_name, division_alias, opp_id, opponents_team_name, opponents_state, opponents_alias
)

select
    game_id,
    team_id,
    team_name,
    team_alias,
    team_state,
    season,

    -- League information
    conference_name,
    conference_alias,
    league_name,
    league_alias,
    division_name,
    division_alias,

    -- Game stats
    total_games,
    wins,
    losses,
    round(wins * 1.0 / nullif(total_games, 0), 3) as win_ratio,

    -- Opponents¨
    opp_id,
    opponents_team_name,
    opponents_state,
    opponents_alias,

    -- Raw totals
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

    -- Averages
    avg_points_per_game,
    avg_assists_per_game,
    avg_field_goals_percentage,
    avg_two_points_percentage,
    avg_three_points_percentage,
    avg_free_throws_percentage

from game_aggregation