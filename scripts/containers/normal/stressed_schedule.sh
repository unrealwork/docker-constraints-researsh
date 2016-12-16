#!/usr/bin/env bash

container_name=stressed;

function docker_container_exist {
    if [ -z "$(docker ps -a  | grep $1)" ]; then
        return 1
    else
        return 0
    fi
}

function clean_up() {
    if [[ $(docker_container_exist ${container_name}) ]]; then
        docker rm -vf ${container_name}
    fi
}

function get_current_mills {
    echo $(($(date +%s%N)/1000000));
    exit 1;
}

core_count=8;
for ((i = 1; i <= $core_count; i++)); do
    docker run --name ${container_name}  -it progrium/stress --cpu ${i}
    sleep 10;
    start_time=$(get_current_mills)
    sleep 900000;
    clean_up
    end_time$(get_current_mills)
done