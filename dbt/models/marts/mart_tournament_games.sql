{{ 
    config(materialized='table') 
}}

with winning_team_players as (
    select
        ps.tournament_game_id,
        ps.player_full_name,
        ps.team_name,
        ps.performance_score,
        tg.winning_team
    from {{ ref('int_ncaa_player_stats') }} ps
    join tournament_games tg
        on ps.game_id = tg.tournament_game_id
    where ps.team = tg.winning_team
),

ranked_players as (
    select *,
        row_number() over(partition by tournament_game_id order by performance_score desc) as rank
    from winning_team_players
),

, top_player_per_game as (
    select *
    from ranked_players
    where rank = 1
)

tournament_games as (
    select * 
    from {{ ref('int_ncaa_tournament_games')}}
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
    p.player_full_name as top_player_name,
    p.performance_score as top_player_score

from tournament_games t
left join top_player_per_game p on t.tournament_game_id = p.game_id