{{ 
    config(materialized='view') 
}}

with player_base as (
    select *
    from {{ ref('stg_ncaa_player_play_by_play') }}
)

, player_aggregation as (
    select
        player_id,
        player_name,
        season,
        team,
        opponents,
        
        -- Basic sums of points
        sum(case when event = 'threepointmade' then 1 else 0 end) as three_point_shots_made,
        sum(case when event = 'twopointmade' then 1 else 0 end) as two_point_shots_made,
        sum(case when event_type = 'freethrowmade' then 1 else 0 end) as freethrows_made,
        sum(case when event = 'assist' then 1 else 0 end) as assists,
        sum(case when event = 'turnover' then 1 else 0 end) as turnovers,
        sum(case when event = 'block' then 1 else 0 end) as blocks,
        sum(case when event = 'steal' then 1 else 0 end) as steals,

        -- Total points made
        count(*) filter (where event_type in ('threepointmade', 'twopointmade', 'freethrowmade')) as scoring_events_count

        -- Used for averages per game
        count(distinct game_id) as total_games,

    from player_base
    group by player_id, player_name, season, team, opponents
)

select
    {{ dbt_utils.generate_surrogate_key(['player_id', 'season']) }} as player_season_id,
    player_id,
    game_id,
    player_name,
    season,
    team,
    opponents,
    total_games,
    three_point_shots_made,
    two_point_shots_made,
    freethrows_made,
    assists,
    turnovers,
    blocks,
    steals,
    scoring_events_count,
    total_points

from player_aggregation