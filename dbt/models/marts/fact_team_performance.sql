{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_team_game_stats') }}
)

, dim_teams as (
    select * 
    from {{ ref('dim_teams')}}
)

select 
    game_id,
    
    -- Team dimensions
    t.team_id,
    b.season,
    t.team_name,
    t.team_alias,
    t.team_state,
    t.conference_name,
    t.conference_alias,
    t.league_name,
    t.league_alias,
    t.division_name,
    t.division_alias,

    -- Stats
    b.total_games,
    b.wins,
    b.losses,
    b.win_ratio,

    -- Opponents
    o.team_id as opponents_id,
    o.team_name as opponents_team_name,
    o.team_state as opponents_state,
    o.team_alias as opponents_alias,

    -- Totals
    b.total_points,
    b.total_field_goals,
    b.total_free_throws_made,
    b.total_assists,
    b.total_rebounds,
    b.total_defensive_rebounds,
    b.total_offensive_rebounds,
    b.total_blocks,
    b.total_steals,
    b.total_turnovers,

    -- Averages
    b.avg_points_per_game,
    b.avg_assists_per_game,
    b.avg_field_goals_percentage,
    b.avg_two_points_percentage,
    b.avg_three_points_percentage,
    b.avg_free_throws_percentage

from base b
left join dim_teams t on b.team_id = t.team_id
left join dim_teams o on b.opp_id = o.team_id
