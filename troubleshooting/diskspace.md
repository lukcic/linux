# Disk space

## No space left on device

To check:

- df -h
- quota
- inodes amount
- broken fs (dmesg)
- temp files upload (/tmp on separate small partition)

Good practices

- check open descriptors (`lsof | grep -i deleted`), descriptors leak
- lower root blocks reservation (`tune2fs -m`)
- delete large unused files (`ncdu`, `du`)
- monitor inodes amount (`df -i`)
- if `open()` then `close()`

1kB = 1000B
1KiB = 1024B (kibibyte)

```sh
fdisk -l /dev/sda1
# 1023 MiB

mkfs.ext4 /dev/sda1
# 261888 4k blocks and 65536 inodes

mount /dev/sda1 /mnt/sda1/

df -hl /mnt/sda1/
# Size  Used    Avail
# 989M  24K     922M

# 922 != 989

user@localhost$ dd if=/dev/zero of=full count=2048 bs=1M
# No space left on device
# 921 MiB written

root@localhost$ dd if=/dev/zero of=full count=2048 bs=1M
# No space left on device
# 972 MiB written
# only 922 MiB was available!
```

During filesystem creation, some disk space is allocated for:

- block allocation tables
- inodes
- journal - logs for track file changes
- superblock data
- filesystem

In ext filesystems root user has `reserved block count`. 

```sh
tune2fs -l /dev/sda1 | grep -i 'reserved block count'
# 13094
# with block size 4096
```

13094 * 4096 = 53633024

53633024 / 1024 /1024 = 51MiB

972 - 921 = 51 MiB

Reserved space for root is needed to allow access the server for troubleshooting. Size of reserved blocks depends on
partition size. Fot 10TB disk reserved space is around 500GiB.

Changing reserved blocks amount:

```sh
tune2fs -m 0 /dev/sda1 
```

Disabling block reservation should be done for storage (additional disk), not for boot drive.

### Empty dir and empty file

Full disk doesn't allow empty directory creation, but it will allow empty file creation.

Directory is never empty (`.` and `..`). File metadata is stored inside
inodes (already created). Filename is saved in `directory entry`. Directory connects file with inode, inode connects
file with physical data.

`inode` - data structure used for storing information about files and directories (inode number, filetype, permissions,
size, modification time, creation time, access time). Stores also links amount and data pointer. Everything except name
- name is inside catalog.

`ls -i` -inode listing

```
root@pve1:/proc# df -i /
Filesystem            Inodes IUsed   IFree IUse% Mounted on
/dev/mapper/pve-root 4554752 84723 4470029    2% 
```

### cp and mv

```sh
# creating 4 files
echo data > data
echo one > one
echo two > two
echo three > three
echo three
#three

ls -i *
#1966092 data  1966095 one  1966098 three  1966097 two

cp data three

ls -i *
#1966092 data  1966095 one  1966098 three  1966097 two

cat three
#data

mv data three

ls
one  three  two

ls -i *
#1966095 one  1966092 three  1966097 two

cat three
data
```

Copying - changes file content, inode remains the same.

Moving (renaming) - new filename is assigned to old inode number. Overridden file inode is removed. 

In linux while opening file, syscall `open` creates file descriptor. App works then on descriptors located in
`/proc/PID_ID/fd`. `/proc` is a bridge between kernel and user space, virtual filesystem.

`lsof` - list open files (descriptors)

Descriptors:

- 0 - stdout
- 1 - stdin
- 2 - stderr

These descriptors are always opened by every process in Linux.

If file is deleted while it's descriptor is opened by other process, file content can be accessed by
`/proc/PID_ID/fd/FD_NUMBER`, e.g. `/proc/12345/fd/3`.

If process writes to file (e.g. logfile) and disk space ends, deletion of file won't free up space as long as file
descriptor is used by process. Process must be killed, or file content must be overridden (cleaned) without inode change or
deleting open descriptors.

```sh
cat /dev/null > file
# or
> file
```

To clean logfile:

```sh
cp access_log access_log.old && > access_log
```

`mv` cannot be used because, wont's change inode, so process will be still writing to the full file.

## Too many open files

Process opened maximum amount of files - each process has limit of open files.

Error codes:

```sh
errno 24
24 Too many open files
```

User limits:

```sh
root@pve1:/proc# ulimit -a

real-time non-blocking time  (microseconds, -R) unlimited
core file size              (blocks, -c) 0
data seg size               (kbytes, -d) unlimited
scheduling priority                 (-e) 0
file size                   (blocks, -f) unlimited
pending signals                     (-i) 30884
max locked memory           (kbytes, -l) 996724
max memory size             (kbytes, -m) unlimited
open files                          (-n) 1024
pipe size                (512 bytes, -p) 8
POSIX message queues         (bytes, -q) 819200
real-time priority                  (-r) 0
stack size                  (kbytes, -s) 8192
cpu time                   (seconds, -t) unlimited
max user processes                  (-u) 30884
virtual memory              (kbytes, -v) unlimited
file locks                          (-x) unlimited
```

In Linux everything is a file, so everything is counted in limits:

- files
- catalogs
- devices (/dev/tty, dev/null)
- FIFO files (pipe)
- sockets
- symbolic links

Process limits:

```sh
root@pve1:/proc# prlimit
RESOURCE   DESCRIPTION                              SOFT       HARD UNITS
AS         address space limit                 unlimited  unlimited bytes
CORE       max core file size                          0  unlimited bytes
CPU        CPU time                            unlimited  unlimited seconds
DATA       max data size                       unlimited  unlimited bytes
FSIZE      max file size                       unlimited  unlimited bytes
LOCKS      max number of file locks held       unlimited  unlimited locks
MEMLOCK    max locked-in-memory address space 1020645376 1020645376 bytes
MSGQUEUE   max bytes in POSIX mqueues             819200     819200 bytes
NICE       max nice prio allowed to raise              0          0
NOFILE     max number of open files                 1024    1048576 files
NPROC      max number of processes                 30884      30884 processes
RSS        max resident set size               unlimited  unlimited bytes
RTPRIO     max real-time priority                      0          0
RTTIME     timeout for real-time tasks         unlimited  unlimited microsecs
SIGPENDING max number of pending signals           30884      30884 signals
STACK      max stack size                        8388608  unlimited bytes
```

```sh
root@pve1:/proc# cat /proc/34/limits

Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        0                    unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             30884                30884                processes
Max open files            1024                 4096                 files
Max locked memory         8388608              8388608              bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       30884                30884                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

### Changing limits

Soft limit - no root privileges needed to change (max hard limit).

```sh
# Changing limits
/etc/security/limits.conf

systemctl edit nginx
#[Service]
#LimitNOFILE=65535

#ulimit - only in current session
#prlimit - changing on working process
```

What to remember about limits:

- proxy services need limit x2 (inbound and outbound)
- `open()` with `close()`