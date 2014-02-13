#!/bin/bash

if [ "x${SERF_SELF_ROLE}" != "xlb" ]; then
    echo "Not an lb. Ignoring member join."
    exit 0
fi

rm /tmp/frontend.cfg
rm /tmp/backend.cfg

serf members -role=web -status=alive | while read host ip status tags; do
    if [[ -z $tags ]]; then exit 0; fi

    declare -A hash
    IFS=',' read -a array <<< "$tags"
    for i in "${array[@]}"; do IFS="=" read k v <<< "$i"; hash[$k]=$v; done

    IFS=";" read -a frontend  <<< "${hash["frontend"]}"
    for i in "${frontend[@]}"; do echo "$i" >> /tmp/frontend.cfg; done
     
    IFS=";" read -a backend  <<< "${hash["backend"]}"
    for i in "${backend[@]}"; do echo "$i" >> /tmp/backend.cfg; done
done

cat /docker-serf/etc/haproxy.cfg.base /tmp/frontend.cfg /tmp/backend.cfg > /docker-serf/etc/haproxy.cfg

supervisorctl restart haproxy
