# Networking Debugging

## Overview



## Debugging Tools


### Trace monitoring

Run the following commands as root to add tracing of packets

```
iptables -t raw -A PREROUTING -p icmp -j TRACE
iptables -t raw -A OUTPUT -p icmp -j TRACE
```


### Connection tracking

Install the tools

```
sudo apt install conntrack
```


