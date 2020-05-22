# Docker container for EPICS
docker image that syncs your workspace in your host machine and mount it on the virtual box.

## Installed versions:
- EPICS 3.15.8 (depfault)
- EPICS 7.0.3.1
- IPAC  2.15
- SEQ   2.2.3-4
- SSCAN R2-11
- CALC  R5-4-2
- ANYS  R4-39
- AUTOSAVE R5-10-1
- BUSY  R1-7-2
- AREADETECTOR R3-9
- PyEpics
- Caproto

## Operating system & Compiler
- Ubuntu 20.04
- GCC/G++ 8
- Python 3.8

## Usage
Build docker image
```
docker build -t epics-base .
```

Edit enviornment variables in ```epics-docker-export```:
````LDIR = refers to the path which you want to mount on the docker image at /home/$USER/workspace/```

To start, run:
```docker-compose run --rm epics-base "/bin/bash"```


## Note
1. for the time being areadetector does not build. it is missing pva link. it can be disabled.

