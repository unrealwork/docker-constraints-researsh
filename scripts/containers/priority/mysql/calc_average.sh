#!/usr/bin/env bash
pid=$(pgrep mysqld)
if [[ -z ${pid} ]]; then
    echo "There is no running instance of mysql daemon (mysqld)"
    exit 1;
fi;

if [[ -z $1 ]]; then
    echo "You need specify interval in seconds";
fi;

function calc() { awk "BEGIN{print $*}"; }

function ticks_by_pid() {
    #files
    local pid_stats_file='/proc/'$1'/stat';
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
    local start_ticks=$(ticks_by_pid ${pid})
    sleep $1
    local end_ticks=$(ticks_by_pid ${pid})
    #calculations
    local total_ticks=$(calc ${end_ticks}-${start_ticks})
    local hertz=$(getconf CLK_TCK)
    local cpu_usage=$(calc 100*'(('${total_ticks}/${hertz}')'/$1')')
    echo ${cpu_usage}
}

avg_cpu_usage $1

exit 0;

