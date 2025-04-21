{{ 
    config(materialized='table') 
}}

select
    {{ dbt_utils.generate_surrogate_key(['season', 'round']) }} as tournament_id,
    season,
    round

from {{ ref('int_ncaa_tournament_games') }}