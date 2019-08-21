base:
  '*':
    - init.env_init

  my_app:
    - match: nodegroup
    - init.env_init_app

  'os:Redhat':
    - match: grain
    - init.env_init_redhat 
