base:
  'prep-tomcat-1':
    - init.sysctl
  'gw':
    - match: nodegroup
    - init.env_init
