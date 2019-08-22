chains_of_filter:
  input:
    chain_name: INPUT
  output:
    chain_name: OUTPUT
  forward:
    chain_name: FORWARD

ip_address:
  company_ip_1:
    ip: 111.200.241.178
  saltmaster_ip_1:
    ip: 10.172.21.208

service_port:
  ssh_port:
    port: 5122
  dns_port:
    port: 53
  zabbix_in_port:
    port: 10050
  zabbix_out_port:
    port: 10051
  mysql_port:
    port: 3306

service_proto:
  tcp_proto:
    proto: tcp
  udp_proto:
    proto: udp
