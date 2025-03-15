# bash

## Command history

Equivalent of `zsh_stats`:

```sh
history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
```

## Constructions

### hashmaps

```sh
declare -A -r VERSIONS=(
    ["kubeadm"]="1.23"
    ["kubelet"]="1.18"
    ["kubectl"]="1.11"
)

# printing a value
echo "${VERSIONS["kubeadm"]}"

# in a loop

for version in "${!VERSIONS[@]}"; do
    echo "Name: $version is installed in version: ${VERSIONS[$version]}"
done

# deleting a value
unset VERSIONS["kubeadm"]
```

## Script rules

### beginning

Without target shell, script will run in current user shell and inherent all shell variables (no sandboxing).

```sh
#!/usr/bin/env bash
set -euox pipefail

# -u - undefined variable, if any variable is undefined, exit
# -e - exit code, if any equals 0, then exit
# -o - options
# pipefail - if any piped command fails, exit
```

### trap

```sh
#!/usr/bin/env bash
set -x
trap read debug

# -x - print all debug data (values)
# trap - will aks for confirmation before each command run 
```

### shellcheck

Tool for analyzing script quality.

```sh
shellcheck script.sh
```

### Check parameters

`-z` - zero length

```sh
if [ -z "$1" ]; then
    echo "Installation directory haven't been set!"
    exit
fi
```

```sh
cd /tmp/directory || { echo "ERROR! No /tmp/directory found!"; exit 1; }
```

### lock

Do not run script twice.

```sh
if [ -f /tmp/lock.file ]; then
    echo "Wait until first run of script ends!"
    exit
fi

touch /tmp/lock.file
```

### check last command

```sh
if [ $? -ne 0 ]; then
    echo "Something went wrong at..."
    exit
fi
```
