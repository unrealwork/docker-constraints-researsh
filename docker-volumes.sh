#!/usr/bin/env bash

prefix=docker.volume.
metric_used=used
metric_used_percent=used_percent
docker_volumes_directory=/var/lib/docker/volumes/


function send_network_command {
    echo -e $@> /dev/tcp/hbs.axibase.com/9081
}

function send_series {
    local entity=$1
    local metric=$2
    local value=$3
    local datetime=$4
    local command="series e:$entity m:$metric=$value d:"'"'${datetime}'"';
    echo ${command}
    send_network_command ${command}
}


function parse_entity () {
    local original_name=$@;
    echo "${original_name/$docker_volumes_directory/''}"
}


function get_current_iso_time {
    echo $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    exit 1;
}

function calc() { awk "BEGIN{print $*}"; }

function get_docker_file_system_size {
    local available=$(df -P ${docker_volumes_directory} | tail -1 | awk '{print $4}')
    local used=$(df -P ${docker_volumes_directory} | tail -1 | awk '{print $3}')
    echo $(calc ${available}+${used})
}
result=$(bash -c 'du -s '${docker_volumes_directory}'*')
array=(${result})
array_length=${#array[@]}

datetime=$(get_current_iso_time)

echo $(get_docker_file_system_size);
for (( c=0; c<$array_length; c+=2 ))
do
    byte_size=${array[c]};
    entity=$(parse_entity ${array[c+1]})
    metric_used_name=${prefix}${metric_used}
    send_series ${entity} ${metric_used_name} ${byte_size} ${datetime}

    metric_used_percent_name=${prefix}${metric_used_percent}
    used_percent=$(calc ${byte_size}/$(get_docker_file_system_size)*100);
    send_series ${entity} ${metric_used_percent_name} ${used_percent} ${datetime}
done