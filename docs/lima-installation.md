# Lima Installation

## Overview

Steps to install the Lima virtual machine orchestrator


## Lima Setup

### Installation

* Simply install using [homebrew](https://formulae.brew.sh/formula/lima)
* Run this command

```
brew install lima
```


### Create instance config

* Lima takes a YAML file that specifies some aspects of the VM
* Since this doesn't seem to support env variable interpolation, we need to generate it
* Run the following from the root of this repo

```
cd setup/lima
./create_template.sh
```


### Running Lima instance

* Run the following commands from the `setup/lima` directory

```
export LIMA_INSTANCE=tce
limactl start --name=tce ./ubuntu-2204-lts.yaml
```

### Connecting to the VM

* Lima picks up the instance name from the environment
* Run this command 

```
lima uname -a
```

* This executes the command on the VM
* Running the following gets a shell

```
lima bash -l
```
