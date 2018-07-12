{% set device_directory = grains['id'] %}

make sure the device directory is presents:
    file.directory:
        - name: /tmp/{{ device_directory }}

{% for item in pillar['collect_show_commands'] %}

{{ item.command }}:
    junos.cli:
        - name: {{ item.command }}
        - dest: /tmp/{{ device_directory }}/{{ item.command }}.txt
        - format: text

{% endfor %}
