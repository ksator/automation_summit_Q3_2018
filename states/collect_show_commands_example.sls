show_version:
    junos.cli:
        - name: show version
        - dest: /tmp/show_version.txt
        - format: text
show_chassis_hardware:
    junos.cli:
        - name: show chassis hardware
        - dest: /tmp/show_chassis_hardware.txt
        - format: text
