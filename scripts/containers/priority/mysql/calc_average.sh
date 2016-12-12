#!/usr/bin/env bash
pid=$(pgrep mysqld)
if [[ -z ${pid} ]]; then
    echo "There is no running instance of mysql daemond (mysqld)"
    exit 1;
fi;

function calc() { awk "BEGIN{print $*}"; }

function average_pid_cpu_usage() {
    #files
    local pid_stats_file='/proc/'$1'/stat';
    local proc_uptime_file='/proc/uptime'
    #extract values
    local stats_values=($(<${pid_stats_file}))
    local uptime_values=($(<${proc_uptime_file}))
    #variables
    local hertz=$(getconf CLK_TCK)
    local uptime=(${uptime_values[0]})
    local utime=${stats_values[14]}
    local stime=${stats_values[15]}
    local cutime=${stats_values[16]}
    local cstime=${stats_values[17]}
    local starttime=${stats_values[22]}
    #calculations
    local total_time=$(calc ${utime}+${stime}+${cutime}+${cstime})
    local seconds=$(calc -${uptime}+${starttime}/${hertz})
    local cpu_usage=$(calc 100*'(('${total_time}/${hertz}')'/${seconds}')')
    echo ${cpu_usage}
}

average_pid_cpu_usage ${pid}
exit 0;

