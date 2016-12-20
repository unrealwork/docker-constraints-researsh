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

function get_current_mills {
    echo $(($(date +%s%N)/1000000));
    exit 1;
}

function send_statistic {
    echo -e "property e:stressed-configuration k:id=$1 t:cpu  ms:"$(get_current_mills)" v:start_time="$2" v:end_time="$3" v:options="$4> /dev/tcp/hbs.axibase.com/9081
}


core_count=8;
clean_up
for ((i = 1; i <= $core_count; i++)); do
    echo ${i}" configuration is started";
    options="--cpu "${i}"";
    docker run --name ${container_name} -it progrium/stress ${options} &
    echo "Warm up!";
    sleep 10;
    start_time=$(get_current_mills)
    sleep 10;
    clean_up
    end_time=$(get_current_mills)
    echo "Sending statistic about the configuration";
    send_statistic conf${i} ${start_time} ${end_time} ${options}
done