proxy:
    proxytype: junos
    host: 100.123.1.2
    username: jcluser
    port: 830
    passwd: Juniper!1
loopback: 192.179.0.73
local_asn: 110
neighbors:
   - interface: ge-0/0/0
     asn: 109
     peer_ip: 192.168.0.5 
     local_ip: 192.168.0.4
     peer_loopback: 192.179.0.95
