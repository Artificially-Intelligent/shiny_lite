#!/bin/bash 

if [ -z "${WWW_DIR}" ]; then
    echo "WWW_DIR not specified, shiny server run as default value: /srv/shiny-server/www"
    export WWW_DIR=/srv/shiny-server/www
fi
mkdir -p $WWW_DIR
chown $SHINY_USER.$SHINY_GROUP -R $WWW_DIR

if [ -z "${LOG_DIR}" ]; then
    echo "LOG_DIR not specified, shiny server run as default value: /var/log/shiny-server"
    export LOG_DIR=/var/log/shiny-server
fi
mkdir -p $LOG_DIR
chown $SHINY_USER.$SHINY_GROUP -R $LOG_DIR
