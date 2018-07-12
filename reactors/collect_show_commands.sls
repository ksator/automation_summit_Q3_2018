{% if data['data'] is defined %}
{% set d = data['data'] %}
{% else %}
{% set d = data %}
{% endif %}

automate_show_commands:
    local.state.apply:
        - tgt: "{{ d['hostname'] }}"
        - arg:
            - collect_show_commands_and_archive_to_git
