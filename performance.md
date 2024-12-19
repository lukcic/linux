# Performance

## Sysbench

```sh
sysbench --threads=4  --time=30 --cpu-max-prime=20000 cpu run
```

```sh
CPU speed:
    events per second: 16535.42

General statistics:
    total time:                          30.0005s
    total number of events:              496087

Latency (ms):
         min:                                    0.58
         avg:                                    0.60
         max:                                    3.71
         95th percentile:                        0.69
         sum:                               299952.33

Threads fairness:
    events (avg/stddev):           49608.7000/2150.23
    execution time (avg/stddev):   29.9952/0.00
```

## fio

Disk testing

```sh
--direct # if true use non-buffered I/O
--sync # synchronous I/O for writes
```

```sh
SIZE="256M"

# Sequential read
fio --name=job-r --rw=read --size=$SIZE --ioengine=libaio --iodepth=4 --bs=128K --direct=1

# Sequential write
fio --name=job-w --rw=write --size=$SIZE --ioengine=libaio --iodepth=4 --bs=128k --direct=1

# Random read
fio --name=job-randr --rw=randread --size=$SIZE --ioengine=libaio --iodepth=32 --bs=4K --direct=1 

# Random write
fio --name=job-randw --rw=randwrite --size=$SIZE --ioengine=libaio --iodepth=32 --bs=4k --direct=1
```