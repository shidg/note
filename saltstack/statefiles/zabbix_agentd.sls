/usr/lib/systemd/system/zabbix_agentd.service:
  file.managed:
    - source: salt://files/zabbix_agentd.service
    - user: root
    - group: root
    - mask: 644

enable zabbix_agentd:
  service.running:
    - name: zabbix_agentd
    - enable: true
