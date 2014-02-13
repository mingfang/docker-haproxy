#!/bin/bash

serf members -role=web -status=alive | while read host ip status tags; do
    if [[ -z $tags ]]; then exit 0; fi

    IFS=',' read -a array <<< "$tags"
    declare -A hash
    for i in "${array[@]}"; do IFS="=" read k v <<< "$i"; hash[$k]=$v; done

    IFS=";" read -a frontend  <<< "${hash["frontend"]}"
    for i in "${frontend[@]}"; do echo "frontend=$i"; done
     
    IFS=";" read -a backend  <<< "${hash["backend"]}"
    for i in "${backend[@]}"; do echo "backend=$i"; done
done

