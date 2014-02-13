#!/bin/sh
exec serf agent -bind=$BIND $TAGS -event-handler "member-join=/docker-serf/bin/join.sh" -event-handler "member-leave=/docker-serf/bin/join.sh"
