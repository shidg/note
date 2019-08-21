base:
  'prep-tomcat-1':
    - iptables.common.init
    - iptables.outgoing.web
    - iptables.outgoing.ntpd
