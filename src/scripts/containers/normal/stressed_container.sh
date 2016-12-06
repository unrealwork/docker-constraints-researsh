#!/usr/bin/env bash
CONTAINER_NAME=stressed
ARGS=$1
docker rm -f ${CONTAINER_NAME}
docker pull progrium/stress
docker run --name ${CONTAINER_NAME}  -it progrium/stress ${ARGS}
