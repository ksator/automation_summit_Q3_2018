configure_bgp:
    junos.install_config:
        - name: salt://bgp.conf
        - timeout: 20
        - replace: False
        - overwrite: False
        - comment: "configured with SaltStack using the model bgp"
