# TC Network Experiments

## Overview

Experiments with network shaping on Linux with Docker


## Notes

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

### Docker

* [nginx image](https://hub.docker.com/_/nginx)
