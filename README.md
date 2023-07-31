# TC Network Experiments

## Overview

Experiments with network shaping on Linux with Docker


## Notes

### Trying out nginx

Running this command

```
docker run -d -v $HOME/Downloads:/usr/share/nginx/html:ro --network networktest nginx
```

## References

### Docker

* [nginx image](https://hub.docker.com/_/nginx)
