{{ 
    config(materialized='view') 
}}

with player_base as (
    select *
    from {{ ref('stg_ncaa_player_play_by_play') }}
)

, player_aggregation as (
    select
        play_id,
        player_id,
        player_name,
        season,
        game_id,
        team,
        team_id,
        opponents,
        
        -- Basic sums of points
        sum(case when event = 'threepointmade' then 1 else 0 end) as three_point_shots_made,
        sum(case when event = 'twopointmade' then 1 else 0 end) as two_point_shots_made,
        sum(case when type_of_event = 'freethrowmade' then 1 else 0 end) as freethrows_made,
        sum(case when event = 'assist' then 1 else 0 end) as assists,
        sum(case when event = 'turnover' then 1 else 0 end) as turnovers,
        sum(case when event = 'block' then 1 else 0 end) as blocks,
        sum(case when event = 'steal' then 1 else 0 end) as steals,
        sum(case when event = 'rebound' then 1 else 0 end) as rebounds,

        -- Total points made
        sum(case when type_of_event in ('threepointmade', 'twopointmade', 'freethrowmade') then 1 else 0 end) as scoring_events_count,

        -- Used for averages per game
        count(distinct game_id) as total_games,

    from player_base
    group by play_id, player_id, player_name, season, game_id, team, team_id, opponents
)

select
    play_id,
    player_id,
    player_name,
    season,
    game_id,
    team,
    team_id,
    opponents,
    total_games,
    three_point_shots_made,
    two_point_shots_made,
    freethrows_made,
    assists,
    turnovers,
    blocks,
    steals,
    rebounds,
    scoring_events_count

from player_aggregation