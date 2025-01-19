#!/usr/bin/env bash

ssh -T pve2.lukcic.net << EOF
echo "The current local working directory is: $PWD"
echo "The current remote working directory is: \$PWD"
EOF

#The current local working directory is: /Users/lukaszcichecki/lukcic/projects/linux/bash_scripting
#The current remote working directory is: /root