#!/usr/bin/env bash

DEFAULT_SLEEP_PERIOD=15;
function get_stats_file() {
        if [[ -z $1 ]]; then
            echo "/proc/stat";
        else
            echo "/proc/$1/stat"
        fi
        exit 0;
}

function calc() { awk "BEGIN{print $*}"; }

function ticks_by_file() {
    #files
    local pid_stats_file=$1;
    local proc_uptime_file='/proc/uptime'
    #extract values
    local stats_values=($(<${pid_stats_file}))
    local uptime_values=($(<${proc_uptime_file}))
    #variables
    local uptime=(${uptime_values[0]})
    local utime=${stats_values[13]}
    local stime=${stats_values[14]}
    local cutime=${stats_values[15]}
    local cstime=${stats_values[16]}
    local starttime=${stats_values[21]}
    #calculations
    local total_time=$(calc ${utime}+${stime}+${cutime}+${cstime})
    echo ${total_time}
    exit 0;
}

function avg_cpu_usage() {
    local start_ticks=$(ticks_by_file $2)
    sleep $1;
    local end_ticks=$(ticks_by_file $2)
    #calculations
    local total_ticks=$(calc ${end_ticks}-${start_ticks})
    local hertz=$(getconf CLK_TCK)
    local cpu_usage=$(calc 100*'(('${total_ticks}/${hertz}')'/$1')')
    echo ${cpu_usage}
}


function get_current_mills {
    echo $(($(date +%s%N)/1000000));
    exit 1;
}

function send_statistic {
    echo -e "series e:dkr.axibase.com m:cpu_usage="$1" ms:"$(get_current_mills)" t:proc="$2 > /dev/tcp/hbs.axibase.com/9081
}

if [[ $# == 0 && $# > 2 ]]; then
    echo "Incorrect number of args"
fi;





while :
do
  overall_loading=$(avg_cpu_usage ${DEFAULT_SLEEP_PERIOD} $(get_stats_file))
  mysql_loading=$(avg_cpu_usage ${DEFAULT_SLEEP_PERIOD} $(get_stats_file $(pgrep mysqld)) )
  send_statistic ${overall_loading} "overall"
  send_statistic ${mysql_loading} "mysql"
done


exit 0;

