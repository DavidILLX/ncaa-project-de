{#
    This macro returns readable description of event
#}

{% macro get_event(event) -%}

    case {{dbt.safe_cast("event", api.Column.translate_type("string"))}}
        when 'block' then 'Block'
        when 'threepointmiss' then 'Missed 3PT Shot'
        when 'freethrow' then 'Free Throw'
        when 'twopointmade' then 'Made 2PT Shot'
        when 'rebound' then 'Rebound'
        when 'assist' then 'Assist'
        when 'steal' then 'Steal'
        when 'ejection' then 'Ejection'
        when 'twopointmiss' then 'Missed 2PT Shot'
        when 'fieldgoal' then 'Field Goal'
        when 'personalfoul' then 'Personal Foul'
        when 'threepointmade' then 'Made 3PT Shot'
        when 'turnover' then 'Turnover'
        when 'flagrantfoul' then 'Flagrant Foul'
        when 'offensivefoul' then 'Offensive Foul'
        when 'technicalfoul' then 'Technical Foul'
        when 'fouldrawn' then 'Foul Drawn'
        when 'null' then 'Unknown'
        when 'attemptblocked' then 'Blocked Shot Attempt'
        else 'Other'
    end

{%- endmacro%}