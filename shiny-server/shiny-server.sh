#!/bin/sh

if [ -z "${PORT}" ]; then
    echo "PORT not specified, using default value: 8080"
    export PORT=8080
fi

export SHINY_USER=shiny
export SHINY_GROUP=shiny

#if [ -z "${PUID}" ]; then
#    echo "PUID not specified, shiny server run as default value: 1000"
#    export PUID=1000
#fi

#if [ -z "${PGID}" ]; then
#    echo "PGID not specified, shiny server run as default value: 1000"
#    export PGID=1000
#fi
#

## Create non root user to run shinyserver 
#groupadd -r --gid $PGID shinyserver && useradd --no-log-init -r -g $PGID -u $PUID shinyserver

# if config dir is empty copy file there for use in cont-init.d scripts
if [ -z "$(ls -A -- "/etc/shiny-server/")" ]; then
    cp ${SCRIPTS_DIR}/default_install_packages.csv /etc/shiny-server/default_install_packages.csv
    cp ${SCRIPTS_DIR}/template-shiny-server.conf /etc/shiny-server/template-shiny-server.conf
fi

# Run init scripts
mkdir -p /etc/cont-init.d/
if [ -z "$(ls -A -- "/etc/cont-init.d/")" ]; then
    echo "Default startup scripts copied to emply dir /etc/cont-init.d/"
    cp ${SCRIPTS_DIR}/cont-init.d-defaults/* /etc/cont-init.d/
fi

chmod +700 -R /etc/cont-init.d/

for f in /etc/cont-init.d/*; do
    echo "starting $f"
    bash "$f" -H 
    echo "finished $f"
done

if [ "$APPLICATION_LOGS_TO_STDOUT" != "false" ];
then
    # push the "real" application logs to stdout with xtail in detached mode
    exec xtail /var/log/shiny-server/ &
fi

if [ "$PRIVILEGED" = "true" ];
then
    exec shiny-server 2>&1
else
    exec gosu $SHINY_USER shiny-server 2>&1
fi