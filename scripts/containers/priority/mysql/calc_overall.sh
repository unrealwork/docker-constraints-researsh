#!/bin/bash
# by Paul Colby (http://colby.id.au), no rights reserved ;)

DEFAULT_SLEEP_PERIOD=15;

PREV_TOTAL=0
PREV_IDLE=0

function send_statistic {
    echo -e "series e:dkr.axibase.com m:proc_stat.cpu_usage="$1" ms:"$(get_current_mills)" t:proc="$2 > /dev/tcp/hbs.axibase.com/9081
}

while true; do
  # Get the total CPU statistics, discarding the 'cpu ' prefix.
  CPU=(`sed -n 's/^cpu\s//p' /proc/stat`)
  IDLE=${CPU[3]} # Just the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done

  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  echo -en "\rCPU: $DIFF_USAGE%  \b\b"
  # send_statistic ${DIFF_USAGE} "overall"
  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"

  # Wait before checking again.
  sleep ${DEFAULT_SLEEP_PERIOD};
done