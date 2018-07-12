{% if data['data'] is defined %}
{% set d = data['data'] %}
{% else %}
{% set d = data %}
{% endif %}

automated_configuration_backup:
    local.state.apply:
        - tgt: "{{ d['hostname'] }}"
        - arg:
            - collect_configuration_and_archive_to_git
