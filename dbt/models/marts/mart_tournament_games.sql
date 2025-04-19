{{ 
    config(materialized='table') 
}}

with tournament_games as (
    select * 
    from {{ ref('int_ncaa_tournament_games')}}
)

, winning_team_players as (
    select
        tg.tournament_game_id,
        ps.player_id,
        ps.player_name,
        ps.team_id,
        ps.team,
        tg.winning_team,
        ((ps.three_point_shots_made + ps.two_point_shots_made + ps.freethrows_made) * 0.7 + 
        ps.rebounds * 0.6 + ps.assists * 0.7 + ps.steals * 0.4 + 
        ps.blocks * 0.5 - ps.turnovers * 0.5) as performance_score
    from {{ ref('int_ncaa_player_stats') }} ps
    join tournament_games tg
        on ps.team_id = tg.win_team_id
    where ps.team = tg.winning_team
)

, ranked_players as (
    select *,
        row_number() over(partition by tournament_game_id order by performance_score desc) as rank
    from winning_team_players
)

, top_player_per_game as (
    select *
    from ranked_players
    where rank = 1
)

select 
    t.tournament_game_id,
    t.season,
    t.game_date,
    t.winning_team,
    t.winning_team_points,
    t.losing_team,
    t.losing_team_points,
    t.point_difference,
    p.player_name as top_player_name,
    p.performance_score as top_player_score

from tournament_games t
left join top_player_per_game p on t.win_team_id = p.team_id