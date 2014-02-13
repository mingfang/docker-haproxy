if [ "x${SERF_SELF_ROLE}" != "xlb" ]; then
    echo "Not an lb. Ignoring member leave"
    exit 0
fi

while read line; do
    NAME=`echo $line | awk '{print $1 }'`
    sed -i'' "/${NAME} /d" /docker-serf/etc/haproxy.cfg
done

supervisorctl restart haproxy
