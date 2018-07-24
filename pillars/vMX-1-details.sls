proxy:
    proxytype: junos
    host: 100.123.1.1
    username: jcluser
    port: 830
    passwd: Juniper!1
loopback: 192.179.0.95
local_asn: 109
neighbors:
   - interface: ge-0/0/0
     asn: 110
     peer_ip: 192.168.0.4 
     local_ip: 192.168.0.5
     peer_loopback: 192.179.0.73
