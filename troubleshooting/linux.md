# Linux debugging

## strace

shc - shell compiler (compiles scripts to binary)

```sh
shc -f input_script.sh -o output_file
```

```sh
strace -ff -s 1000 output_file

-p [PID]        # strace running process
-ff             # follow children processes (newly created), 
                # sometimes children processes must be recreated - multi thread apps
-s 1000         # print strings 1000 bytes to screen (default 128 bytes string output)
-t              # check instruction start time (add timestamp)
-T              # add command execution time at the end
-tt             # more detailed, max tttt
-e [function]   # search for executed functions
-e execve       # look for binaries running in program
```

## ldd

Shows all shared libraries used by process.

```sh
ldd /usr/bin/binary
```

Libraries with one leading zero usually are symlinks to lib with full version, e.g. 3.5.0.

## proc + oom

/proc/...

### cmdline

Check how the process was started:

```sh
vim /proc/[PID]/cmdline

# /usr/bin/apache2^@-k^@start^@
```

### exe

Symlink to process' binary.

### cwd

Current working directory - home dir where process was started.

### limits

Limits set to the process.

### oom files

Out of memory. Out of memory killer (oem killer) process. Used to free memory when it ends.

`oom_score` - rating given to process from oom killer algorithm. The higher rate, the higher probability, that process
will be killed. Score is calculated based on process memory usage.

`oom_adj` - adjust, fix for rating, if -17, then process will never be killed (like e.g. sshd).

`oom_score_adj` - overrides memory score algorithm (values: -1000 - 1000). If 0, then do not override oom default
algorithm. -500 means reduce memory used by process by 50% before calculation.

### choom tool

```sh
choom -p [PID]
```
