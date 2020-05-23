#!/bin/bash 

if [ ! -z "${SHINYCODE_GITHUB_REPO}" ];
then
    echo "Copying contentes of github repo $SHINYCODE_GITHUB_REPO to $WWW_DIR"
    if [ -z "${GITHUB_DIR}" ]; then
        echo "GITHUB_DIR not specified, shiny server run as default value: $WWW_DIR"
        export GITHUB_DIR=$WWW_DIR
    fi
    mkdir -p $GITHUB_DIR
    chown $SHINY_USER.$SHINY_GROUP -R $GITHUB_DIR
    
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
