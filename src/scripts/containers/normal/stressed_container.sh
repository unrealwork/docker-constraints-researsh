#!/usr/bin/env bash
CONTAINER_NAME=stressed
docker rm -f ${CONTAINER_NAME}
docker pull dkuffner/docker-stress
docker run --name ${CONTAINER_NAME}  -it progrium/stress $1 $
