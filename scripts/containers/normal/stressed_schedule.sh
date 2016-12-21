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

function calc() { awk "BEGIN{print $*}"; }

function send_statistic {
    local command="property e:stressed-configuration k:id=$1 t:cpu  ms:"$(get_current_mills)" v:start_time="$2" v:end_time="$3" v:options="'"'$4'"';
    echo ${command}
    echo -e ${command} > /dev/tcp/hbs.axibase.com/9081
}


core_count=8;
clean_up
for ((i = 0; i <= $core_count; i++)); do
    echo ${i}" configuration is started";
    options="--cpu "${i}"";
    echo "Warm up!";
    start_time=$(calc $(get_current_mills)+ $(calc $1*1000));
    echo ${start_time}
    if [[ ${i} > 0 ]]; then
        docker run --name ${container_name} -it progrium/stress ${options} --timeout $(calc $1+$2)
    else
        echo "Just sleep without loading";
        sleep $(calc $1+$2)
    fi;
    clean_up
    end_time=$(get_current_mills)
    echo ${end_time}
    echo "Sending statistic about the configuration";
    send_statistic conf${i} ${start_time} ${end_time} "$options"
done