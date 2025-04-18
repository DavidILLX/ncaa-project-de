{{
    config(
        materialized='view'
    )
}}

with tournament_game_stats as 
(
  select game_date, season, win_seed, win_name, win_alias, win_school_ncaa, win_pts, lose_seed,
  lose_name, lose_alias, lose_school_ncaa, lose_pts,
    row_number() over(partition by game_date) as rn
  from {{ source('staging','ncaa_historical_tournament_games') }}
  where player_id is not null 
)

select
    -- Identification
    {{dbt_utils.generate_surrogate_key(['win_team_id', 'lose_team_id', 'game_date'])}} as tournament_game_id,
    {{dbt.safe_cast("win_team__id", api.Column.translate_type('string'))}},
    {{dbt.safe_cast("lose_team_id", api.Column.translate_type('string'))}},

    game_date,
    season,
    win_seed,
    win_name as winning_team_name,
    win_alias as winning_team_alias,
    win_school_ncaa as winning_team_school,
    win_pts as winning_team_points,
    lose_seed,
    lose_name as losing_team_name,
    lose_alias as losing_team_alias,
    lose_school_ncaa as losing_team_school,
    lose_pts as losing_team_points,
    
from ncaa_dataset.ncaa_historical_tournament_games,
where rn = 1

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}