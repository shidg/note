disable ctrl-alt-del:
  file.absent:
    - name: /usr/lib/systemd/system/ctrl-alt-del.target

reload init:
  cmd.run:
    - name: /sbin/init q
    - require:
      - file: disable ctrl-alt-del
