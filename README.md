# TC Network Experiments

## Overview

Experiments with network shaping on Linux with Docker

There are several approaches here that all arrive at the same point of being able to run Docker
commands to start experiments with 

* VMWare Ubuntu 22.04 LTS
* Lima to start Mac VM
* Docker Desktop on Mac


## Quickstart 




## Setup Instructions

### VMWare 

* Install VMWare Fusion on Mac (or workstation on Linux/Windows)
* Create a Ubuntu 22.04LTS VM
* Follow the [docker installation docs](./docs/docker-installation)


### Lima

* Follow the [lima installation docs](./docs/lima-installation)
* Follow the [docker installation docs](./docs/docker-installation)

### Docker Desktop

* Simply install [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
* TODO: Add more details here



## Experiments

TODO: Split this section out into separate docs files


### Lima iPerf with traffic control on VM

* Follow the Lima and Docker instructions above
* Install iperf in the VM and on the host
  * On host (mac in this case): `brew install iperf`
  * On VM (Ubuntu): `sudo apt install iperf`
* On the VM install net tools: `sudo apt install net-tools`

We can now run iperf locally (on the host) and test the bandwidth from a Lima VM

* Run the following command in a Mac shell

```
iperf -s

```

* Should give this output

```
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size:  128 KByte (default)
------------------------------------------------------------
```

* Run a lima shell with `lima bash -l`
* Run the iperf client

```
iperf -c 192.168.5.2
------------------------------------------------------------
Client connecting to 192.168.5.2, TCP port 5001
TCP window size:  434 KByte (default)
------------------------------------------------------------
[  1] local 192.168.5.15 port 45114 connected with 192.168.5.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.0000-10.0112 sec  2.63 GBytes  2.25 Gbits/sec
```

* The IP address here is a "magic" one that always refers to the host
* Run the following command in the Lima shell

```
sudo tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
```

* Repeat the test in a Lima shell

```
iperf -c 192.168.5.2
------------------------------------------------------------
Client connecting to 192.168.5.2, TCP port 5001
TCP window size: 85.0 KByte (default)
------------------------------------------------------------
[  1] local 192.168.5.15 port 50370 connected with 192.168.5.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  1] 0.0000-11.9544 sec  1.38 MBytes   965 Kbits/sec
```

* TODO: Add how to undo this


### Docker on Linux using TC

TODO: Add details of iperf server on host (VM or bare metal) running a Docker container 
with iperf client and use TC to throttle network connection

TODO: Note that on Linux need to add the hack that gets the local host name docker.internal.local



## Notes

These are not steps to run, just things I tried


### Trying out nginx

Running these commands

```
docker network create -d bridge networktest

docker run -d -v $HOME/Downloads:/usr/share/nginx/html:ro --network networktest nginx
```


### Trying tc command

Showing the setup for existing networks

```
tc qdisc show

qdisc noqueue 0: dev lo root refcnt 2 
qdisc fq_codel 0: dev ens160 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc noqueue 0: dev docker0 root refcnt 2 
qdisc noqueue 0: dev br-0adcd1b3cd09 root refcnt 2 
qdisc noqueue 0: dev veth1852642 root refcnt 2 
```

This command was run after creating the new docker network in the section above.


## References

### Network tools

* [Masquerade vs SNAT](https://unix.stackexchange.com/questions/21967/difference-between-snat-and-masquerade)
* 

### Docker

* [Linux post install steps](https://docs.docker.com/engine/install/linux-postinstall/)
* [nginx image](https://hub.docker.com/_/nginx)

### Lima

* [Lima homebrew formula](https://formulae.brew.sh/formula/lima)
* [Colima homebrew formula](https://formulae.brew.sh/formula/colima)
* [Colima github](https://github.com/abiosoft/colima)
* [Lima repo and information](https://github.com/lima-vm/lima)
* [Lima homepage](https://lima-vm.io/)
* [Colima nerdctl](https://github.com/containerd/nerdctl) for interacting with containerd
* [Lima Ubuntu LTS config](https://github.com/lima-vm/lima/blob/master/examples/ubuntu-lts.yaml)


### VMWare

* [Unofficial Ubuntu VMWare Fusion Guide](https://communities.vmware.com/t5/VMware-Fusion-Documents/The-Unofficial-Fusion-13-for-Apple-Silicon-Companion-Guide/ta-p/2939907)


### Linux

* [Ubuntu Linux 6.2 Kernel install](https://www.omgubuntu.co.uk/2023/08/ubuntu-22-04-linux-kernel-6-2)
* [IP Masquerading HOWTO](https://tldp.org/HOWTO/html_single/IP-Masquerade-HOWTO/)
* [Changing Ubuntu Timezone with timedatectl](https://www.hostinger.co.uk/tutorials/how-to-change-timezone-in-ubuntu/#:~:text=To%20do%20so%2C%20open%20Terminal,is%20using%20the%20timedatectl%20command.)
