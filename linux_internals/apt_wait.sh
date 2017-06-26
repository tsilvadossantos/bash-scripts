#!/bin/bash
#wait a process to exit before spawning new ones
#usage: bash apt_wait.sh <process_name> 

i=0
function wait_procnames {
    while true; do
        alive_pids=()
        for pname in "$@"; do
            if [ "$(pgrep "$pname")" ]; then
                alive_pids+=("$pname ")
            fi
        done
        if [ "${#alive_pids[@]}" -eq 0 ]; then
            apt-get update && apt-get install -y <package-name>
	          break
        else
	   clear
	   printf "Waiting for: %s\n" "${alive_pids[@]} $i seconds"
        fi
        sleep 1
	((i=i+1))
    done
}
wait_procnames "$@"
