# Buffer Pool Size of Total RAM No data的问题
avg by (node_name) ((mysql_global_variables_innodb_buffer_pool_size{service_name=~""} * 100)) /on (node_name) (avg by (node_name) (node_memory_MemTotal_bytes{node_name=~""}))
