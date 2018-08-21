#!/bin/bash
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP
docker run --read-only -it -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix burc-lite /bin/bash 
xhost - $IP
