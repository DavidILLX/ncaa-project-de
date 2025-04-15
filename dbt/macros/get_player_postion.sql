{#
    This macro returns players position on the team
#}

{% macro get_player_position(position) -%}

    case {{dbt.safe_cast("position", api.Column.translate_type("string"))}}
        when 'F' then 'Forward'
        when 'C' then 'Center'
        when 'F-G' then 'Forward-Guard'
        when 'C-F' then 'Center-Forward'
        when 'G' then 'Guard'
        when 'G-F' then 'Guard-Forward'
        when 'F-C' then 'Forward-Center'
        else 'Not Available'
    end

{%- endmacro%}