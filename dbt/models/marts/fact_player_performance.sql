{{ 
    config(materialized='table') 
}}

with base as (
    select *
    from {{ ref('int_ncaa_player_season_stats') }}
    where player_status <> 'RET' -- Filter out retired players
)

, dim_players as (
    select *
    from {{ ref('dim_player')}}
) 

, dim_teams as (
    select * 
    from {{ ref('dim_teams')}}
)

, base_performance as (
    select
        player_id,
        team_id,
        season,
        sum(points) as total_points,
        sum(assists) as total_assists,
        sum(rebounds) as total_rebounds,
        sum(offensive_rebounds) as total_offensive_rebounds,
        sum(defensive_rebounds) as total_defensive_rebounds,
        sum(steals) as total_steals,
        sum(blocks) as total_blocks,
        sum(turnovers) as total_turnovers,
        sum(fouls) as total_fouls,
        count(*) as total_games
       
    from base
    group by player_id, team_id, season
)

, performance as (
    select *,
        -- Creating performance score
        (total_points * 0.7 + total_offensive_rebounds * 0.5 + total_defensive_rebounds * 0.5 + 
        total_assists * 0.7 + total_steals * 0.4 + total_blocks * 0.5 - total_turnovers * 0.5) as performance_score,
        
        -- Ranking based on púerformance score 
        dense_rank() over(partition by team_id order by (total_points * 0.7 + total_offensive_rebounds * 0.5 + total_defensive_rebounds * 0.5 + 
        total_assists * 0.7 + total_steals * 0.4 + total_blocks * 0.5 - total_turnovers * 0.5)) as player_rank

    from base_performance
)

, performance_evaluation as (
    select *,
        case
            when performance_score > 50 then true else false
        end as draft_prospect
    from performance
)

, stats as (
    select
        -- Dimension players
        p.player_id,
        p.player_full_name,
        p.physical_stats,
        p.player_position,
        p.player_status,
        p.birthplace_state,
        p.birthplace_country,

        -- Dimension teams
        t.team_id,
        t.team_name,
        t.team_alias,
        t.team_state,
        t.conference_name,
        t.conference_alias,
        t.league_name,
        t.league_alias,
        t.division_name,
        t.division_alias,

        -- Facts
        b.season,
        b.total_points,
        b.total_assists,
        b.total_rebounds,
        b.total_steals,
        b.total_blocks,
        b.total_turnovers,
        b.total_fouls,
        b.total_games,

        -- Caculated ranks
        round(b.performance_score, 1) as performance_score,
        b.draft_prospect

    from performance_evaluation b
    left join dim_players p on b.player_id = p.player_id
    left join dim_teams t on b.team_id = t.team_id

)

select * from stats