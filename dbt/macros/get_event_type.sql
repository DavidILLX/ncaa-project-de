{#
    This macro returns readable description of event type
#}

{% macro get_event_type(event_type) -%}

    case {{dbt.safe_cast("event_type", api.Column.translate_type("string"))}}
        when 'kickball' then 'Kick Ball Violation'
        when 'freethrow' then 'Free Throw'
        when 'ejection' then 'Ejection'
        when 'teamtimeout' then 'Team Timeout'
        when 'endperiod' then 'End of Period'
        when 'lineupchange' then 'Lineup Change'
        when 'threepointmiss' then 'Missed 3PT Shot'
        when 'tvtimeout' then 'TV Timeout'
        when 'freethrowmade' then 'Made Free Throw'
        when 'twopointmiss' then 'Missed 2PT Shot'
        when 'possession' then 'Change of Possession'
        when 'freethrowmiss' then 'Missed Free Throw'
        when 'turnover' then 'Turnover'
        when 'flagranttwo' then 'Flagrant 2 Foul'
        when 'deadball' then 'Dead Ball'
        when 'review' then 'Play Under Review'
        when 'officialtimeout' then 'Official Timeout'
        when 'delay' then 'Delay of Game'
        when 'threepointmade' then 'Made 3PT Shot'
    end

{%- endmacro%}