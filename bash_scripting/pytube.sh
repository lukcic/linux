#!/bin/bash


list=$(cat list.txt)

#echo $list[0]

for i in ${list[@]}; do
	function retry { echo "Currently downloaded file: " $i && pytube "\"$i"\" && echo "success" || (echo "fail" && retry) }; retry 
done
