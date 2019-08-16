dev:
  group.present:
    - gid: 2000
{% for user in pillar['user_list'] %}
{{ user }}:
  user.present:
    - shell: /bin/bash
#    - password: $6$TU2qjXfIM.gH0rzS$oJdNasP7pMJKxKi/0rcy5AExmnkSpa4IbGCtDIpLfLEfep5sahiLwOvDpCKZjtLAXrUfaDPdr6vUAAtsJ/tRB0
    - password: $1$nJSp0n9n$i7ifp97ZQt1Au61eaoDWe1
    - groups:
      - dev
    - require:
      - group: dev
{% endfor %}
