#!/bin/bash
# https://www.tecmint.com/bash-for-loop-linux

x=("ala" "ma kota" "test 1 2 3")

echo "Witohout quotes"
for i in ${x[@]}; do echo $i; done

echo "With quotes"
for i in "${x[@]}"; do echo $i; done

echo "Different"
while read -r y; do
    echo  "${y}"
done < <(echo "ala" "ma kota" "test 1 2 3")
