## Preparation
To calculate CPU usage for a specific process you'll need the following:

1. [`/proc/uptime`](http://man7.org/linux/man-pages/man5/proc.5.html)
   - `#1` uptime of the system (seconds)
2. [`/proc/[PID]/stat`](http://man7.org/linux/man-pages/man5/proc.5.html)
   - `#14` `utime` - CPU time spent in user code, measured in *clock ticks*
   - `#15` `stime` - CPU time spent in kernel code, measured in *clock ticks*
   - `#16` `cutime` - **Waited-for children's** CPU time spent in user code (in *clock ticks*)
   - `#17` `cstime` - **Waited-for children's** CPU time spent in kernel code (in *clock ticks*)
   - `#22` `starttime` - Time when the process started, measured in *clock ticks*
3. Hertz (number of clock ticks per second) of your system.
   - In most cases, [`getconf CLK_TCK`](http://pubs.opengroup.org/onlinepubs/009695399/utilities/getconf.html) can be used to return the number of clock ticks.
   - The [`sysconf(_SC_CLK_TCK)`](http://pubs.opengroup.org/onlinepubs/009695399/functions/sysconf.html) C function call may also be used to return the hertz value.

---
### Calculation

First we determine the total time spent for the process:

    total_time = utime + stime
    
We also have to decide whether we want to include the time from children processes. If we do, then we add those values to `total_time`:

    total_time = total_time + cutime + cstime

Next we get the total elapsed time in *seconds* since the process started:

    seconds = uptime - (starttime / Hertz)

Finally we calculate the CPU usage percentage:

    cpu_usage = 100 * ((total_time / Hertz) / seconds)

---

### See also
  > [Top and ps not showing the same cpu result](http://unix.stackexchange.com/a/58541)

  > [How to get total cpu usage in Linux (c++)](http://stackoverflow.com/a/3017438/1806289)

  > [Calculating CPU usage of a process in Linux](http://stackoverflow.com/a/1424556/1806289)