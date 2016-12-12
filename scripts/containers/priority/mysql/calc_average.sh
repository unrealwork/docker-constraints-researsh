#!/usr/bin/env bash
pid=$(pgrep mysqld)
if [[ -z ${pid} ]]; then
    echo "There is no running instance of "
    exit 1;
fi;

function calc() { awk "BEGIN{print $*}"; }

#files
pid_stats_file='/proc/'${pid}'/stat';
proc_uptime_file='/proc/uptime'
#extract values
stats_values=($(<${pid_stats_file}))
uptime_values=($(<${proc_uptime_file}))
#variables
hertz=$(getconf CLK_TCK)
uptime=(${uptime_values[0]})
utime=${stats_values[14]}
stime=${stats_values[15]}
cutime=${stats_values[16]}
cstime=${stats_values[17]}
starttime=${stats_values[22]}
#calculations
total_time=$(calc ${utime}+${stime}+${cutime}+${cstime})
seconds=$(calc -${uptime}+${starttime}/${hertz})
cpu_usage=$(calc 100*'(('${total_time}/${hertz}')'/${seconds}')')
echo ${cpu_usage}


