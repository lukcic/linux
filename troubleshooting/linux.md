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
