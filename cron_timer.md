# Cron/timers

## Cron

Daemon that runs commands at schedule.

Uses `sh` shell, so profile variables doesn`t work - use script! or set shell and variables on the beginning of crontab command:

```sh
* * * * * /usr/bin/bash -i -c 'command'
* * * * * /usr/bin/bash -i -c 'source ~/.profile; command'
# -i -interactive mode
```

Binary: `/usr/sbin/cron` (`crond` in RHEL)

Cron tables: `/var/spool/cron`

Every user have its own table file.

Log: `/var/cron/log`

System CRONs:

```sh

crontab -e      # open cron editor (your cron table) in $EDITOR
crontab -l      # list cron table
crontab -r      # removes your cron table
crontab [FILE]  # will instal FILE as your cron table (removes old version)

sudo crontab -e [USERNAME]  # modification other users cron table

/etc/crontab        # system cron table, used by administrator
/etc/cron.d         # crontab used by software packages

/etc/cron.daily 
/etc/cron.hourly 
/etc/cron.monthly 
/etc/cron.weekly     
# folder with software scripts, fired by by /etc/crontab

/etc/cron.allow     # file with user names that can have cron tables
/etc/cron.deny      # file with user names that can`t have cron tables
```

## Comment inf cron table

```sh
minute hour day_of_month month day_of_week [COMMAND_PATH]   #space is separator, command can have spaces and tabs, 
                                                            #new command in new line, % is newline (text after this will be send to command stdin), if % is needed in command use \%
minute 0-59  
hour 0-23
day of a month 1-31
month 1-12 or names
day of a week 0-6 or names (sunday is 0 and 7)

*       -any value
12      -normal value
1-7     -range
1-30/2  -range with jump value
1,2,3   -lisy of values

If day_of_month and day_of_week both are selected, then cron do task every day that match (given day of week and every day of month).
```

### Examples

```sh
45 10 * * 1-5      #from monday to friday at 10:45

0 4 * * Sun (/usr/bin/mysqlcheck -u maintenance --optimize --all-databases)     # run mysql check every sunday at 4:00 AM

20 1 * * * find /tmp -mtime +7 -type f -exec rm -f { } ';'                      # everydat at 1:20 AM delete from /tmp files that wasn't modified in last 7 days (;is needeb dy exec of find, means end)

30 4 25 * * /usr/bin/mail -s "Czas zabrać się za raporty TPS" owen@atrust.com%Raporty TPS muszą być gotowe do końca miesiąca! Weź się do roboty!%%Z poważaniem,%cron 
#every 25th of month at 4;30 send email
```

### Debugging

Use output redirection in crontab command:

```sh
* * * * * command > /tmp/cron.log 2>&1
```

## flock

File lock. Used to block task start until different task is done (overlapping prevention). Can be used to disallow running scripts simultaneously.

```sh
flock /tmp/lockfile command1
flock /tmp/lockfile command2

# -w 60 -wait 60s (timeout)
# -w 0 -wait endlessly (default)
```

`command2` will start running just after `command1` ends.

## Systemd timers

Mechanism similar to cron delivered by systemd. Timers can be written like crond (eg. every sunday at 7 AM) and with coordination with other tasks (eg. 30s after system starts).

### Files

```sh
timer unit - scheduler file (*.timer)
service unit - service that timer runs (*.service)

Systemd timer types (in seconds):
OnActiveSec         #untill ths timer activtion
OnBootSec           #untill system boot
OnStartupSec        #untill SYSTEMD starts
OnUnitActiveSec     #untill last activity time of given unit
OnUnitInactiveSec   #untill no activity time of given unit
OnCalendar          #given date time

OnActiveSec=30      #means „30 secsonds after timer activated”
OnBootSec=2h 1m     #means 2h 1 minute after system booted
```

### Commands

```sh
systemctl list-timers   #list timers

cat /usr/lib/systemd/system/system-tmpfiles-clean.timer 
# shows timer details

[Unit]
Description=Daily Cleanup of Temporary Directories
[Timer]             # timer needs fist activation trigger, in this case OnBootSec
OnBootSec=15min     # timer will start 15 mins after system boots
OnUnitActiveSec=1d  # and second time after one day of last start
```

If service unit isn`t declared in timer, systemd looks for service with the same name:

```sh
# /usr/lib/systemd/system/systemd-tmpfiles-clean.service

[Unit]
Description=Cleanup of Temporary Directories
DefaultDependencies=no
Conflicts=shutdown.target
After=systemd-readahead-collect.service systemd-readahead-replay.service
local-fs.target time-sync.target
Before=shutdown.target
[Service]
Type=simple
ExecStart=/usr/bin/systemd-tmpfiles --clean
IOSchedulingClass=idle
```

This service can bu started manually like others: `systemctl start systemd-tmpfiles-clean.service`. The advantage of using timers instead cron is log given while starting scheduled services!

If timer should start with system, add this into the end of .timer file:

```sh
[Install]
WantedBy=multi-user.target
```

`AccuracySec` - delay timer activation of random amount of time

```sh
OnCalendar:
2017-07-04         #4 july 2017 r. o godz. 00:00:00 (midnight)
Fri-Mon *-7-4      #4 july every year, but only when it is from friday to monday
Mon-Wed *-*-* 12:00:00  # at 12.00 every monday, tuesday and wensday
Mon 17:00:00            # mondays at 5 P.M. 
weekly                  # every week (monday) at mignight (00:00:00)
monthly                 # every month (fisth day) at 00:00:00 (midnight)
*:0/10                  # every 10 minutes (starts at minute 0) 
*-*-* 11/12:10:0        # every day at 11:10 i 23:10 (at 11:10:00 and twelve hours after 11:10:00)
```

### Temporary timers

```sh
systemd-run --on-calendar '*:0/10' /bin/sh -c "cd /app && git pull" #pull git repo every 10 minutes
```

systemd will return temporary timer id:

- systemctl list-timers run-8823.timer
- systemctl list-units run-8823.timer

```sh
sudo systemctl stop run-8823.timer      # stop temporary timer
```

Temporary timers works until reboot. Systemd saves them in: `/run/systemd/system`. This type of timer can be stopped and installed in `/etc/systemd/system`.
