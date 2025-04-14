{{
    config(
        materialized='view'
    )
}}

with play_by_play as 
(
  select *,
    row_number() over(partition by scheduled_date) as rn
  from {{ source('staging','ncaa_player_play_by_play') }}
  where game_id is not null 
)