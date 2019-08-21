install_iptables:
  pkg.installed:
    - name: iptables-services
    - order: 1

clear_iptables:
  cmd.run:
  {% if grains['osfinger'] == 'CentOS-6' %}
    - name: service iptables stop && echo >/etc/sysconfig/iptables 
  {% elif grains['osfinger'] == 'CentOS Linux-7' %}
    - name: systemctl stop iptables && echo >/etc/sysconfig/iptables
  {% endif %}

# white_list
{% for key, value in pillar['ip_address'].items() %}
{{ key }}_input:
  iptables.insert:
     - position: 1
     - table: filter
     - chain: INPUT
     - jump: ACCEPT
     - source: {{ value['ip'] }}
{{ key }}_output:
  iptables.insert:
     - position: 1
     - table: filter
     - chain: OUTPUT
     - jump: ACCEPT
     - destination: {{ value['ip'] }}
{% endfor %}

drop_invalid_input:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: INPUT
    - jump: DROP
    - match: state
    - connstate: INVALID

accept_estab_input:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: RELATED,ESTABLISHED

ssh_input:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ pillar['service_port']['ssh_port']['port'] }}
    - proto: tcp

icmp_input:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - proto: icmp
    - match: icmp
    - icmp-type: echo-request

drop_invalid_output:
  iptables.insert:
    - position: 1
    - table: filter
    - chain: OUTPUT
    - jump: DROP
    - match: state
    - connstate: INVALID

accept_estab_output:
  iptables.insert:
    - position: 2
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - match: state
    - connstate: RELATED,ESTABLISHED

{% for key, value in pillar['web_out'].items() %}
{{ key }}_output:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - dport: {{ value['port'] }}
    - proto: {{ value['proto'] }}
{% endfor %}

{% for key, value in pillar['service_proto'].items() %}
dns_output_with_{{ key }}:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - dport: 53
    - proto: {{ value['proto'] }}
{% endfor %}

ntp_output:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - proto: tcp
    - dport: 123

icmp_output:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - proto: icmp
    - match: icmp
    - icmp-type: echo-request

{% for key, value in pillar['chains_of_filter'].items() %}
{{ key }}_policy:
  iptables.set_policy:
    - table: filter
    - chain: {{ value['chain_name'] }}
    - policy: DROP
{% endfor %}

save iptables rules:
  cmd.run:
    - name: service iptables save
