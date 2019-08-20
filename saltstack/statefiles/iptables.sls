clear_iptables:
  cmd.run:
  {% if grains['osfinger'] == 'CentOS-6' %}
    - name: service iptables stop && echo >/etc/sysconfig/iptables 
  {% elif grains['osfinger'] == 'CentOS Linux-7' %}
    - name: systemctl stop iptables && echo >/etc/sysconfig/iptables
  {% endif %}

#### 添加白名单ip
{% for fw, rule in pillar['white_list'].items() %}
{{ fw }}_INPUT:
  iptables.insert:
     - position: 1
     - table: filter
     - chain: INPUT
     - jump: ACCEPT
     - source: {{ rule['ip'] }}
     - save: True

{{ fw }}_OUTPUT:
  iptables.insert:
     - position: 1
     - table: filter
     - chain: OUTPUT
     - jump: ACCEPT
     - destination: {{ rule['ip'] }}
     - save: True
{% endfor %}

# ssh入站访问
ssh_input:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ pillar['ssh_in']['port'] }}
    - proto: {{ pillar['ssh_in']['proto'] }}
    - save: True

# web访问出站规则
{% for fw, rule in pillar['web_out'].items() %}
{{ fw }}_OUTPUT:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - dport: {{ rule['port'] }}
    - proto: {{ rule['proto'] }}
    - save: Ture
{% endfor %}

# dns出站规则
{% for fw, rule in pillar['dns_out'].items() %}
{{ fw }}_OUTPUT:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: ACCEPT
    - dport: {{ rule['port'] }}
    - proto: {{ rule['proto'] }}
    - save: Ture
{% endfor %}
