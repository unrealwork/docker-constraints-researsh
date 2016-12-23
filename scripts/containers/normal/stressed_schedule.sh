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
    if docker_container_exist ${container_name}; then
    docker rm -f ${container_name}
fi
}

function get_current_iso_time {
    echo $(date -u +"%Y-%m-%dT%H:%M:%SZ")
    exit 1;
}

function calc() { awk "BEGIN{print $*}"; }

function send_network_command {
    local wrapped_command=
    echo $@
    echo -e $@ > /dev/tcp/hbs.axibase.com/9081
}

function send_configuration_entity {
    local command="entity e:stressed-configuration z:"$(date +%Z)
    send_network_command ${command}
}
function send_configuration_property {
    local command="property e:stressed-configurations k:id=$1 t:cpu  d:"'"'$(get_current_iso_time)'"'" v:start_time="$2" v:end_time="$3" v:options="'"'$4'"';
    send_network_command ${command}
}


core_count=8;
clean_up
for ((i = 0; i <= $core_count; i++)); do
    echo ${i}" configuration is started";
    options="--cpu "${i}"";
    echo "Warm up!";
    start_time=$(get_current_iso_time);
    if [[ ${i} > 0 ]]; then
        docker run --name ${container_name} -it progrium/stress ${options} --timeout $(calc $1+$2)
    else
        echo "Just sleep without loading";
        sleep $(calc $1+$2)
    fi;
    clean_up
    end_time=$(get_current_iso_time)
    echo ${end_time}
    echo "Sending statistic about the configuration";
    send_configuration_property conf${i} ${start_time} ${end_time} "$options"
done