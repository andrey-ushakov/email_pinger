#!/bin/bash

pathBase=$1

# Get all directories with email lists
IN_DIRS=($(ls -d ${pathBase}src*))


# Run pinger for each dir
ind=0
for dirpath in "${IN_DIRS[@]}"
do
	((ind++))
	bash pinger.sh $dirpath/ &  PID${ind}=$!
done


# Wait all pingers
ind=0
for dirpath in "${IN_DIRS[@]}"
do
	((ind++))
	wait PID${ind}=$!
done



printf "____________ALL PINGERS DONE____________\n"