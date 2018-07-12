{% if data['data'] is defined %}
{% set d = data['data'] %}
{% else %}
{% set d = data %}
{% endif %}

automated_show_commands_collection:
    local.state.apply:
        - tgt: "{{ d['hostname'] }}"
        - arg:
            - collect_show_commands_and_archive_to_git
