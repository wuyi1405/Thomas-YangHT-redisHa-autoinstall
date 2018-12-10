source ./CONFIG
cat << EOF > haproxy.cfg
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  tune.ssl.default-dh-param 2048

defaults
  log global
  mode http
  option dontlognull
  timeout connect 5000ms
  timeout client  600000ms
  timeout server  600000ms

listen stats
    bind :9091
    mode http
    balance
    stats uri /haproxy_stats
    stats auth admin:admin
    stats admin if TRUE

frontend redis-cluster-$VPORT
   mode tcp
   bind :$VPORT
   default_backend redis-cluster-backend

backend redis-cluster-backend
    mode tcp
    balance roundrobin
    stick-table type ip size 200k expire 30m
    stick on src
    server $NODE1_NAME $NODE1_IP:$MasterPort check
    server $NODE2_NAME $NODE2_IP:$MasterPort check
    server $NODE3_NAME $NODE3_IP:$MasterPort check

EOF

