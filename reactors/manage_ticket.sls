{% if data['data'] is defined %}
{% set d = data['data'] %}
{% else %}
{% set d = data %}
{% endif %}
{% set interface = d['message'].split(' ')[-1] %}
{% set interface = interface.split('.')[0] %}

create_a_new_ticket_or_update_the_existing_one:
    runner.request_tracker_saltstack_runner.create_ticket:
        - args:
            subject: "device {{ d['hostname'] }} had its interface {{ interface }} status that changed"
            text: " {{ d['message'] }}"

show_commands_output_collection:
    local.state.apply:
        - tgt: "{{ d['hostname'] }}"
        - arg:
            - collect_data_locally

attach_files_to_a_ticket:
    runner.request_tracker_saltstack_runner.attach_files_to_ticket:
        - args:
            subject: "device {{ d['hostname'] }} had its interface {{ interface }} status that changed"
            device_directory: "{{ d['hostname'] }}"
        - require:
            - show_commands_output_collection
            - create_a_new_ticket_or_update_the_existing_one
