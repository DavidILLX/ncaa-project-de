{#
    This macro returns readable status for player
#}

{% macro get_player_status(status) -%}

    case {{dbt.safe_cast("status", api.Column.translate_type("string"))}}
        when 'RET' then 'Returned'
        when 'IR' then 'Injured'
        when 'SUS' then 'Suspended'
        when 'D-League' then 'NBA D-League'
        when 'ACT' then 'Active'
        when 'NWT' then 'Not With the Team'
        else 'Not Available'
    end

{%- endmacro%}