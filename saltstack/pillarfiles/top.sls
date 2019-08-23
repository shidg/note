base:
  'prep-tomcat-1':
    - base.init
    - iptables.common.init
    - iptables.outgoing.web
    - iptables.outgoing.ntpd
