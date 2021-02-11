#!/bin/bash

echo "Starting program at $(date)"                              #Command insters date in brackets.
echo "Starting program $0 with $# arguments with PID $$."       #$0 - inserts name of the script, $# - inserts number of args, $$ gives PID of the script

for file in "$@"; do                                            #iterates files in directory from arg
    grep foobar "$file" > /dev/null 2> /dev/null                #when foobar is not in file, grep retuns code 1 (error) that is forwarded to /dev/null
                                                                #stdout is forwarded to /dev/null too

    if [[ $? -ne 0 ]]; then                                     #if return code of last command (grep) not exuals 0 then do
        echo "File $file does not have any foobar, adding one"  
        echo "# foobar" >> "$file"
    fi
done

