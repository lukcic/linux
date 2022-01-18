#!/bin/bash

if [ -f /tmp/lock ]; 
then
    echo "Wait until last script run ends work."
    exit;
else
    touch /tmp/lock
fi

python3 --version

rm -rf /tmp/lock

