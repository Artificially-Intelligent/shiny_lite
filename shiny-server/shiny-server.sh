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

## Create non root user to run shinyserver 
#groupadd -r --gid $PGID shinyserver && useradd --no-log-init -r -g $PGID -u $PUID shinyserver

if [ -z "${DATA_DIR}" ]; then
    echo "DATA_DIR not specified, shiny server run as default value: /srv/shiny-server/data"
    export DATA_DIR=/srv/shiny-server/data
fi
mkdir -p $DATA_DIR
chown $SHINY_USER.$SHINY_GROUP -R $DATA_DIR

if [ -z "${WWW_DIR}" ]; then
    echo "WWW_DIR not specified, shiny server run as default value: /srv/shiny-server/www"
    export WWW_DIR=/srv/shiny-server/www
fi
mkdir -p $WWW_DIR
chown $SHINY_USER.$SHINY_GROUP -R $WWW_DIR

if [ -z "${GITHUB_DIR}" ]; then
    echo "GITHUB_DIR not specified, shiny server run as default value: $WWW_DIR"
    export GITHUB_DIR=$WWW_DIR
fi
mkdir -p $GITHUB_DIR
chown $SHINY_USER.$SHINY_GROUP -R $GITHUB_DIR


if [ -z "${OUTPUT_DIR}" ]; then
    echo "OUTPUT_DIR not specified, shiny server run as default value: /04_output"
    export OUTPUT_DIR=/srv/shiny-server/output
fi
mkdir -p $OUTPUT_DIR
chown $SHINY_USER.$SHINY_GROUP -R $OUTPUT_DIR

if [ -z "${LOG_DIR}" ]; then
    echo "LOG_DIR not specified, shiny server run as default value: /var/log/shiny-server"
    export LOG_DIR=/var/log/shiny-server
fi
mkdir -p $LOG_DIR
chown $SHINY_USER.$SHINY_GROUP -R $LOG_DIR

# Copy container ENV variables to .Reviron so they will be available to shiny
RENV=/home/shiny/.Renviron
printenv > $RENV

if [ ! -z "${SHINYCODE_GITHUB_REPO}" ];
then
    echo "Copying contentes of github repo $SHINYCODE_GITHUB_REPO to $WWW_DIR"
    git clone $SHINYCODE_GITHUB_REPO $GITHUB_DIR
    chown $SHINY_USER.$SHINY_GROUP -R $GITHUB_DIR
else
    if [ "$(ls -A $WWW_DIR)" ]; then
        echo "Shiny web root dir $WWW_DIR successfully mapped to local path"
    else
        ln -s /opt/shiny-server/samples/welcome.html $WWW_DIR/index.html
        ln -s /opt/shiny-server/samples/sample-apps $WWW_DIR/sample-apps
        #cp -R /usr/local/lib/R/site-library/shiny/examples/* $WWW_DIR/
    fi
fi

# if [ -z "${INIT_DIR}" ]; then
#     echo "INIT_DIR not specified, using default value: /etc/cont-init.d/"
#     export INIT_DIR=/etc/cont-init.d/
# fi
# 
# # add / to end of path if its missing
# if [[ ! $INIT_DIR == *"/" ]]; then
#     echo "changed INIT_DIR from $INIT_DIR to $INIT_DIR/"
#     export INIT_DIR=$INIT_DIR/
# fi
# 
# if [ ! -d  "${INIT_DIR}" ]; then
#     echo "INIT_DIR: $INIT_DIR is not mounted. Making dir and filling with default scripts"
#     mkdir -p $INIT_DIR
#     cp /usr/local/lib/shiny-server/cont-init.d-defaults/* $INIT_DIR
# fi
# 
# chmod +700 -R $INIT_DIR
# 
# for f in $INIT_DIR*; do
#     echo "starting $f"
#     bash "$f" -H 
#     echo "finished $f"
# done

if [ "$(ls -A /etc/cont-init.d/)" ]; then
    echo "Default startup scripts copied to emply dir /etc/cont-init.d/"
    cp /usr/local/lib/shiny-server/cont-init.d-defaults/* /etc/cont-init.d/
fi

chmod +700 -R /etc/cont-init.d/

for f in /etc/cont-init.d/*; do
    echo "starting $f"
    bash "$f" -H 
    echo "finished $f"
done

if [ "$(ls -A /etc/shiny-server/)" ]; then
    cp /usr/local/lib/shiny-server/default_install_packages.csv /etc/shiny-server/default_install_packages.csv
    cp /usr/local/lib/shiny-server/template-shiny-server.conf /etc/shiny-server/template-shiny-server.conf
fi

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