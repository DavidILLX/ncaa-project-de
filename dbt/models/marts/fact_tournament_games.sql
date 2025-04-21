{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_tournament_games') }}
)

, dim_tournaments as (
    select *
    from  {{ ref('dim_tournaments')}}
)

select
    -- Tournament match info
    b.tournament_game_id,
    b.season,
    b.round,

    -- Tournament team info
    b.win_team_id,
    b.winning_team,
    b.winning_team_points,
    b.lose_team_id,
    b.losing_team,
    b.losing_team_points,
    b.point_difference,

from base b
left join dim_tournaments t on b.season = t.season and b.round = t.round