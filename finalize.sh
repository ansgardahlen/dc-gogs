#!/bin/sh

source ./gogs.conf

#docker exec --user git dc_gogs bash -c "export USER=git; /app/gogs/gogs admin create-user --name $GOGS_ADMIN --password $GOGS_PASS --email $GOGS_ADMIN_MAIL --admin true"
docker exec --user git dc_gogs bash -c "export USER=git; /app/gogs/gogs admin create-user --name $GOGS_ADMIN --password $GOGS_PASS --email $ADMIN_MAIL --admin "
