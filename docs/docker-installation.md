# Docker installation

## Overview

Installing Docker on Linux (Ubuntu) and any setup/hacking of config to 
get it working with the test setup.


## Steps

* Following these [instructions](https://docs.docker.com/engine/install/ubuntu/)
* Running the following as root to get the install setup

```
apt install ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
```

* Now installing with the following

```
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

* Running post-install step

```
usermod -aG docker fiona
```



