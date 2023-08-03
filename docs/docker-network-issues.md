# Docker Network Issues

## Overview

Containers attached on user-defined bridge networks can't access the internet


## Investigation

### Single Ping 

Running docker with a new network

```
docker network create -d bridge --opt "com.docker.network.bridge.enable_ip_masquerade"="true" newnet

docker run --network newnet --add-host=host.docker.internal:host-gateway -it bash
```

* Running a single ping

```
ping -c 1 www.duckduckgo.com
```

* The logging output gives this

```
xtables-monitor --trace
PACKET: 2 2089bd8f IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=84 TOS=0x0 TTL=64 ID=43751DF 
 TRACE: 2 2089bd8f raw:PREROUTING:rule:0x4:CONTINUE  -4 -t raw -A PREROUTING -p icmp -j TRACE
 TRACE: 2 2089bd8f raw:PREROUTING:return:
 TRACE: 2 2089bd8f raw:PREROUTING:policy:ACCEPT 
 TRACE: 2 2089bd8f nat:PREROUTING:return:
 TRACE: 2 2089bd8f nat:PREROUTING:policy:ACCEPT 
PACKET: 2 d922bdcd IN=br-406f2a425e0c OUT=ens160 MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=84 TOS=0x0 TTL=63 ID=43751DF 
 TRACE: 2 d922bdcd filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 d922bdcd filter:DOCKER-USER:return:
 TRACE: 2 d922bdcd filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 d922bdcd filter:DOCKER-ISOLATION-STAGE-1:rule:0x42:JUMP:DOCKER-ISOLATION-STAGE-2  -4 -t filter -A DOCKER-ISOLATION-STAGE-1 -i br-406f2a425e0c ! -o br-406f2a425e0c -j DOCKER-ISOLATION-STAGE-2
 TRACE: 2 d922bdcd filter:DOCKER-ISOLATION-STAGE-2:return:
 TRACE: 2 d922bdcd filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 d922bdcd filter:FORWARD:rule:0x34:ACCEPT  -4 -t filter -A FORWARD -i br-406f2a425e0c ! -o br-406f2a425e0c -j ACCEPT
```

* Running a different docker container on the default bridge

```
docker run --add-host=host.docker.internal:host-gateway -it bash
```

* Gives this output

```
xtables-monitor --trace
PACKET: 2 119c5605 IN=docker0 MACSRC=2:42:ac:11:0:2 MACDST=2:42:e6:97:7c:13 MACPROTO=0800 SRC=172.17.0.2 DST=52.142.124.215 LEN=84 TOS=0x0 TTL=64 ID=33480DF 
 TRACE: 2 119c5605 raw:PREROUTING:rule:0x4:CONTINUE  -4 -t raw -A PREROUTING -p icmp -j TRACE
 TRACE: 2 119c5605 raw:PREROUTING:return:
 TRACE: 2 119c5605 raw:PREROUTING:policy:ACCEPT 
 TRACE: 2 119c5605 nat:PREROUTING:return:
 TRACE: 2 119c5605 nat:PREROUTING:policy:ACCEPT 
PACKET: 2 2e1c3e85 IN=docker0 OUT=ens160 MACSRC=2:42:ac:11:0:2 MACDST=2:42:e6:97:7c:13 MACPROTO=0800 SRC=172.17.0.2 DST=52.142.124.215 LEN=84 TOS=0x0 TTL=63 ID=33480DF 
 TRACE: 2 2e1c3e85 filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 2e1c3e85 filter:DOCKER-USER:return:
 TRACE: 2 2e1c3e85 filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 2e1c3e85 filter:DOCKER-ISOLATION-STAGE-1:rule:0x4c:JUMP:DOCKER-ISOLATION-STAGE-2  -4 -t filter -A DOCKER-ISOLATION-STAGE-1 -i docker0 ! -o docker0 -j DOCKER-ISOLATION-STAGE-2
 TRACE: 2 2e1c3e85 filter:DOCKER-ISOLATION-STAGE-2:return:
 TRACE: 2 2e1c3e85 filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 2e1c3e85 filter:FORWARD:rule:0x48:ACCEPT  -4 -t filter -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
PACKET: 2 2e1c3e85 IN=docker0 OUT=ens160 MACSRC=2:42:ac:11:0:2 MACDST=2:42:e6:97:7c:13 MACPROTO=0800 SRC=172.17.0.2 DST=52.142.124.215 LEN=84 TOS=0x0 TTL=63 ID=33480DF 
 TRACE: 2 2e1c3e85 nat:POSTROUTING:rule:0x1e:ACCEPT  -4 -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
PACKET: 2 5d0e7204 IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=52.142.124.215 DST=192.168.91.132 LEN=84 TOS=0x0 TTL=128 ID=8322
 TRACE: 2 5d0e7204 raw:PREROUTING:rule:0x4:CONTINUE  -4 -t raw -A PREROUTING -p icmp -j TRACE
 TRACE: 2 5d0e7204 raw:PREROUTING:return:
 TRACE: 2 5d0e7204 raw:PREROUTING:policy:ACCEPT 
PACKET: 2 5d0e7204 IN=ens160 OUT=docker0 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=52.142.124.215 DST=172.17.0.2 LEN=84 TOS=0x0 TTL=127 ID=8322
 TRACE: 2 5d0e7204 filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 5d0e7204 filter:DOCKER-USER:return:
 TRACE: 2 5d0e7204 filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 5d0e7204 filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 5d0e7204 filter:FORWARD:rule:0x4a:ACCEPT  -4 -t filter -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

## References

### Iptables

* [Iptables flowchart](https://stuffphilwrites.com/wp-content/uploads/2014/09/FW-IDS-iptables-Flowchart-v2019-04-30-1.png)
* 