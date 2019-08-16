net.ipv4.ip_local_port_range:
  sysctl.present:
    - value: 1024 65535

net.core.somaxconn:
  sysctl.present:
    - value: 50000

net.core.netdev_max_backlog:
  sysctl.present:
    - value: 3000

kernel.core_uses_pid:
  sysctl.present:
    - value: 1

net.ipv4.tcp_mem:
  sysctl.present:
    - value: 524288 699050 1048576  

net.ipv4.tcp_rmem:
  sysctl.present:
    - value: 4096 8192 4194304

net.ipv4.tcp_wmem:
  sysctl.present:
    - value: 4096 8192 4194304

net.ipv4.tcp_fin_timeout:
  sysctl.present:
    - value: 30

net.ipv4.tcp_max_tw_buckets:
  sysctl.present:
    - value: 3000

net.ipv4.tcp_keepalive_time:
  sysctl.present:
    - value: 1800

net.ipv4.tcp_keepalive_intvl:
  sysctl.present:
    - value: 30

net.ipv4.tcp_keepalive_probes:
  sysctl.present:
    - value: 3

net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1

net.ipv4.tcp_syn_retries:
  sysctl.present:
    - value: 2

net.ipv4.tcp_synack_retries:
  sysctl.present:
    - value: 2

net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1

net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1

net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0

net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1

net.ipv4.tcp_max_orphans:
  sysctl.present:
    - value: 32768

net.ipv4.tcp_orphan_retries:
  sysctl.present:
    - value: 2

fs.file-max:
  sysctl.present:
    - value: 6553560

vm.swappiness:
  sysctl.present:
    - value: 0

vm.max_map_count:
  sysctl.present:
    - value: 2048000

kernel.pid_max:
  sysctl.present:
    - value: 1200000

kernel.threads_max:
  sysctl.present:
    - value: 150000
