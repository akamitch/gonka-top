# We use table mangle (Docker usualy don't touch it)
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -I OUTPUT -j ACCEPT
iptables -t mangle -I PREROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t mangle -I PREROUTING -p tcp -m tcp --dport 22 -j ACCEPT
iptables -t mangle -I PREROUTING -p tcp -m tcp --dport 5000 -j ACCEPT -m comment --comment "gonka"
iptables -t mangle -I PREROUTING -p tcp -m tcp --dport 8000 -j ACCEPT -m comment --comment "gonka"

# example for ML node
#iptables -t mangle -I PREROUTING -s 109.206.182.192/32 -p tcp -m tcp --dport 5050 -j ACCEPT -m comment --comment "net2 network node"
#iptables -t mangle -I PREROUTING -s 109.206.182.192/32 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "net2 network node"

# example for network node
#iptables -t mangle -I PREROUTING -s 24.144.74.84/32 -p tcp -m tcp --dport 9100 -j ACCEPT -m comment --comment "rif ML node"

iptables -t mangle -A PREROUTING -i eth0 -j DROP


