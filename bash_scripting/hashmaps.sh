#!/usr/bin/env bash

set -euo pipefail

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