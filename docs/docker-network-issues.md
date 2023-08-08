# Docker Network Issues

## Overview

Containers attached on user-defined bridge networks can't access the internet


## Possible Resolution

* Seems that the test I did on an x86 machine also uncovered differences in kernel
* I did a full update before installing Docker and this must have triggered the install of the 6.2.x kernel rather than 5.15
* Found information [here](https://www.omgubuntu.co.uk/2023/08/ubuntu-22-04-linux-kernel-6-2)
* Having upgraded twoflower (Linux aarch64 VM on MacOS) docker test with bridge seems to work and ping gets through



## Investigation

### Linux VM Twoflower

This spec

```
lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.2 LTS
Release:	22.04
Codename:	jammy

uname -a
Linux twoflower 5.15.0-78-generic #85-Ubuntu SMP Fri Jul 7 15:29:30 UTC 2023 aarch64 aarch64 aarch64 GNU/Linux
```


#### Single Ping 

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
```

  * I think this is the return route 

```
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


### Linux Desktop 

This spec

```
lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.3 LTS
Release:	22.04
Codename:	jammy

uname -a
Linux manu 6.2.0-26-generic #26~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Jul 13 16:27:29 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

Docker

```
docker version
Client: Docker Engine - Community
 Version:           24.0.5
 API version:       1.43
 Go version:        go1.20.6
 Git commit:        ced0996
 Built:             Fri Jul 21 20:35:18 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.5
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.6
  Git commit:       a61e2b4
  Built:            Fri Jul 21 20:35:18 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.22
  GitCommit:        8165feabfdfe38c65b599c4993d227328c231fca
 runc:
  Version:          1.1.8
  GitCommit:        v1.1.8-0-g82f18fe
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

#### Single ping to router

Ran this command

```
docker run --network newnet --add-host=host.docker.internal:host-gateway -it bash
```

Then a single ping, the tracing output was this

```
xtables-monitor --trace
PACKET: 2 8aefe197 IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=172.20.0.1 LEN=84 TOS=0x0 TTL=64 ID=43254DF 
 TRACE: 2 8aefe197 raw:PREROUTING:rule:0x4:CONTINUE  -4 -t raw -A PREROUTING -p icmp -j TRACE
 TRACE: 2 8aefe197 raw:PREROUTING:return:
 TRACE: 2 8aefe197 raw:PREROUTING:policy:ACCEPT 
PACKET: 2 8aefe197 IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=172.20.0.1 LEN=84 TOS=0x0 TTL=64 ID=43254DF 
 TRACE: 2 8aefe197 nat:PREROUTING:rule:0x18:JUMP:DOCKER  -4 -t nat -A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
 TRACE: 2 8aefe197 nat:DOCKER:return:
 TRACE: 2 8aefe197 nat:PREROUTING:return:
 TRACE: 2 8aefe197 nat:PREROUTING:policy:ACCEPT 
PACKET: 2 27883a8d OUT=br-406f2a425e0c SRC=172.20.0.1 DST=172.20.0.2 LEN=84 TOS=0x0 TTL=64 ID=54308
 TRACE: 2 27883a8d raw:OUTPUT:rule:0x2:CONTINUE  -4 -t raw -A OUTPUT -p icmp -j TRACE
 TRACE: 2 27883a8d raw:OUTPUT:return:
 TRACE: 2 27883a8d raw:OUTPUT:policy:ACCEPT 
```


#### TCP connection

```
PACKET: 2 4b64b42c IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=64 ID=4884DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 4b64b42c raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 4b64b42c raw:PREROUTING:return:
 TRACE: 2 4b64b42c raw:PREROUTING:policy:ACCEPT 
 TRACE: 2 4b64b42c nat:PREROUTING:return:
 TRACE: 2 4b64b42c nat:PREROUTING:policy:ACCEPT 
PACKET: 2 8885cff6 IN=br-406f2a425e0c OUT=ens160 MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=63 ID=4884DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 8885cff6 filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 8885cff6 filter:DOCKER-USER:return:
 TRACE: 2 8885cff6 filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 8885cff6 filter:DOCKER-ISOLATION-STAGE-1:rule:0x42:JUMP:DOCKER-ISOLATION-STAGE-2  -4 -t filter -A DOCKER-ISOLATION-STAGE-1 -i br-406f2a425e0c ! -o br-406f2a425e0c -j DOCKER-ISOLATION-STAGE-2
 TRACE: 2 8885cff6 filter:DOCKER-ISOLATION-STAGE-2:return:
 TRACE: 2 8885cff6 filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 8885cff6 filter:FORWARD:rule:0x34:ACCEPT  -4 -t filter -A FORWARD -i br-406f2a425e0c ! -o br-406f2a425e0c -j ACCEPT
PACKET: 2 e99d8351 IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=64 ID=4885DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 e99d8351 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 e99d8351 raw:PREROUTING:return:
 TRACE: 2 e99d8351 raw:PREROUTING:policy:ACCEPT 
 TRACE: 2 e99d8351 nat:PREROUTING:return:
 TRACE: 2 e99d8351 nat:PREROUTING:policy:ACCEPT 
PACKET: 2 8e4c2144 IN=br-406f2a425e0c OUT=ens160 MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=63 ID=4885DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 8e4c2144 filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 8e4c2144 filter:DOCKER-USER:return:
 TRACE: 2 8e4c2144 filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 8e4c2144 filter:DOCKER-ISOLATION-STAGE-1:rule:0x42:JUMP:DOCKER-ISOLATION-STAGE-2  -4 -t filter -A DOCKER-ISOLATION-STAGE-1 -i br-406f2a425e0c ! -o br-406f2a425e0c -j DOCKER-ISOLATION-STAGE-2
 TRACE: 2 8e4c2144 filter:DOCKER-ISOLATION-STAGE-2:return:
 TRACE: 2 8e4c2144 filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 8e4c2144 filter:FORWARD:rule:0x34:ACCEPT  -4 -t filter -A FORWARD -i br-406f2a425e0c ! -o br-406f2a425e0c -j ACCEPT
PACKET: 2 e810cef1 IN=br-406f2a425e0c MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=64 ID=4886DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 e810cef1 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 e810cef1 raw:PREROUTING:return:
 TRACE: 2 e810cef1 raw:PREROUTING:policy:ACCEPT 
 TRACE: 2 e810cef1 nat:PREROUTING:return:
 TRACE: 2 e810cef1 nat:PREROUTING:policy:ACCEPT 
PACKET: 2 4c1874d7 IN=br-406f2a425e0c OUT=ens160 MACSRC=2:42:ac:14:0:2 MACDST=2:42:a4:c7:f1:f1 MACPROTO=0800 SRC=172.20.0.2 DST=40.89.244.232 LEN=60 TOS=0x0 TTL=63 ID=4886DF SPORT=48454 DPORT=443 SYN 
 TRACE: 2 4c1874d7 filter:FORWARD:rule:0x4e:JUMP:DOCKER-USER  -4 -t filter -A FORWARD -j DOCKER-USER
 TRACE: 2 4c1874d7 filter:DOCKER-USER:return:
 TRACE: 2 4c1874d7 filter:FORWARD:rule:0x4b:JUMP:DOCKER-ISOLATION-STAGE-1  -4 -t filter -A FORWARD -j DOCKER-ISOLATION-STAGE-1
 TRACE: 2 4c1874d7 filter:DOCKER-ISOLATION-STAGE-1:rule:0x42:JUMP:DOCKER-ISOLATION-STAGE-2  -4 -t filter -A DOCKER-ISOLATION-STAGE-1 -i br-406f2a425e0c ! -o br-406f2a425e0c -j DOCKER-ISOLATION-STAGE-2
 TRACE: 2 4c1874d7 filter:DOCKER-ISOLATION-STAGE-2:return:
 TRACE: 2 4c1874d7 filter:DOCKER-ISOLATION-STAGE-1:return:
 TRACE: 2 4c1874d7 filter:FORWARD:rule:0x34:ACCEPT  -4 -t filter -A FORWARD -i br-406f2a425e0c ! -o br-406f2a425e0c -j ACCEPT
PACKET: 2 fc1648f0 OUT=ens160 SRC=192.168.91.132 DST=185.125.190.17 LEN=60 TOS=0x0 TTL=64 ID=10624DF SPORT=58366 DPORT=80 SYN 
 TRACE: 2 fc1648f0 raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 fc1648f0 raw:OUTPUT:return:
 TRACE: 2 fc1648f0 raw:OUTPUT:policy:ACCEPT 
 TRACE: 2 fc1648f0 nat:OUTPUT:return:
 TRACE: 2 fc1648f0 nat:OUTPUT:policy:ACCEPT 
 TRACE: 2 fc1648f0 nat:POSTROUTING:return:
 TRACE: 2 fc1648f0 nat:POSTROUTING:policy:ACCEPT 
PACKET: 2 bd07e2a9 IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=185.125.190.17 DST=192.168.91.132 LEN=44 TOS=0x0 TTL=128 ID=43007SPORT=80 DPORT=58366 SYN ACK 
 TRACE: 2 bd07e2a9 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 bd07e2a9 raw:PREROUTING:return:
 TRACE: 2 bd07e2a9 raw:PREROUTING:policy:ACCEPT 
PACKET: 2 a2a0bf39 OUT=ens160 SRC=192.168.91.132 DST=185.125.190.17 LEN=40 TOS=0x0 TTL=64 ID=10625DF SPORT=58366 DPORT=80 ACK 
 TRACE: 2 a2a0bf39 raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 a2a0bf39 raw:OUTPUT:return:
 TRACE: 2 a2a0bf39 raw:OUTPUT:policy:ACCEPT 
PACKET: 2 a977cdc1 OUT=ens160 SRC=192.168.91.132 DST=185.125.190.17 LEN=127 TOS=0x0 TTL=64 ID=10626DF SPORT=58366 DPORT=80 ACK PSH 
 TRACE: 2 a977cdc1 raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 a977cdc1 raw:OUTPUT:return:
 TRACE: 2 a977cdc1 raw:OUTPUT:policy:ACCEPT 
PACKET: 2 4dcedd4b IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=185.125.190.17 DST=192.168.91.132 LEN=40 TOS=0x0 TTL=128 ID=43008SPORT=80 DPORT=58366 ACK 
 TRACE: 2 4dcedd4b raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 4dcedd4b raw:PREROUTING:return:
 TRACE: 2 4dcedd4b raw:PREROUTING:policy:ACCEPT 
PACKET: 2 e9fa05e3 IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=185.125.190.17 DST=192.168.91.132 LEN=229 TOS=0x0 TTL=128 ID=43009SPORT=80 DPORT=58366 ACK FIN PSH 
 TRACE: 2 e9fa05e3 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 e9fa05e3 raw:PREROUTING:return:
 TRACE: 2 e9fa05e3 raw:PREROUTING:policy:ACCEPT 
PACKET: 2 07d2a4b7 OUT=ens160 SRC=192.168.91.132 DST=185.125.190.17 LEN=40 TOS=0x0 TTL=64 ID=10627DF SPORT=58366 DPORT=80 ACK FIN 
 TRACE: 2 07d2a4b7 raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 07d2a4b7 raw:OUTPUT:return:
 TRACE: 2 07d2a4b7 raw:OUTPUT:policy:ACCEPT 
PACKET: 2 95d57c88 IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=185.125.190.17 DST=192.168.91.132 LEN=40 TOS=0x0 TTL=128 ID=43010SPORT=80 DPORT=58366 ACK 
 TRACE: 2 95d57c88 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 95d57c88 raw:PREROUTING:return:
 TRACE: 2 95d57c88 raw:PREROUTING:policy:ACCEPT 
PACKET: 2 2a34aaec IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=34.117.65.55 DST=192.168.91.132 LEN=64 TOS=0x0 TTL=128 ID=43011SPORT=443 DPORT=35354 ACK PSH 
 TRACE: 2 2a34aaec raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 2a34aaec raw:PREROUTING:return:
 TRACE: 2 2a34aaec raw:PREROUTING:policy:ACCEPT 
PACKET: 2 bb36d2e3 OUT=ens160 SRC=192.168.91.132 DST=34.117.65.55 LEN=68 TOS=0x0 TTL=64 ID=43529DF SPORT=35354 DPORT=443 ACK PSH 
 TRACE: 2 bb36d2e3 raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 bb36d2e3 raw:OUTPUT:return:
 TRACE: 2 bb36d2e3 raw:OUTPUT:policy:ACCEPT 
PACKET: 2 0792101a IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=34.117.65.55 DST=192.168.91.132 LEN=40 TOS=0x0 TTL=128 ID=43012SPORT=443 DPORT=35354 ACK 
 TRACE: 2 0792101a raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 0792101a raw:PREROUTING:return:
 TRACE: 2 0792101a raw:PREROUTING:policy:ACCEPT 
PACKET: 2 096eeb0d IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=198.252.206.25 DST=192.168.91.132 LEN=101 TOS=0x0 TTL=128 ID=43053SPORT=443 DPORT=37278 ACK PSH 
 TRACE: 2 096eeb0d raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 096eeb0d raw:PREROUTING:return:
 TRACE: 2 096eeb0d raw:PREROUTING:policy:ACCEPT 
PACKET: 2 20e9f6ee OUT=ens160 SRC=192.168.91.132 DST=198.252.206.25 LEN=79 TOS=0x0 TTL=64 ID=36026DF SPORT=37278 DPORT=443 ACK PSH 
 TRACE: 2 20e9f6ee raw:OUTPUT:rule:0x6:CONTINUE  -4 -t raw -A OUTPUT -p tcp -j TRACE
 TRACE: 2 20e9f6ee raw:OUTPUT:return:
 TRACE: 2 20e9f6ee raw:OUTPUT:policy:ACCEPT 
PACKET: 2 05ccead6 IN=ens160 MACSRC=0:50:56:e3:7a:86 MACDST=0:c:29:c:d6:d1 MACPROTO=0800 SRC=198.252.206.25 DST=192.168.91.132 LEN=40 TOS=0x0 TTL=128 ID=43054SPORT=443 DPORT=37278 ACK 
 TRACE: 2 05ccead6 raw:PREROUTING:rule:0x5:CONTINUE  -4 -t raw -A PREROUTING -p tcp -j TRACE
 TRACE: 2 05ccead6 raw:PREROUTING:return:
 TRACE: 2 05ccead6 raw:PREROUTING:policy:ACCEPT 
```

## References

### Iptables

* [Iptables flowchart](https://stuffphilwrites.com/wp-content/uploads/2014/09/FW-IDS-iptables-Flowchart-v2019-04-30-1.png)
* 
