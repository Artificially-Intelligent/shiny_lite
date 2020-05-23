#!/bin/bash 

if [ -z "${APP_INIT_TIMEOUT}" ]; then
    echo "APP_INIT_TIMEOUT not specified, shiny server run using default value: 60"
    export APP_INIT_TIMEOUT=60
fi

if [ -z "${APP_IDLE_TIMEOUT}" ]; then
    echo "APP_IDLE_TIMEOUT not specified, shiny server run using default value: 5"
    export APP_IDLE_TIMEOUT=5
fi

if [ -z "${APP_SESSION_TIMEOUT}" ]; then
    echo "APP_SESSION_TIMEOUT not specified, shiny server run using default value: 5"
    export APP_SESSION_TIMEOUT=0
fi

# if running in google cloud run disable incompatible protocols
if [ ! -z "${K_REVISION}" ];
then
    # remaining active protocols: jsonp-polling xhr-polling 
    export SHINY_DISABLE_PROTOCOLS="websocket xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile xdr-polling iframe-xhr-polling"
    echo "K_REVISION ENV Variable set with value '$K_REVISION'. Presuming Google Cloud Run Host, disabling incompatible protocols for shiny server: $SHINY_DISABLE_PROTOCOLS"
fi

#Substitute ENV variable values into template-shiny-server.conf and overwrite shiny-server.conf
if [ -f  "/etc/shiny-server/shiny-server.conf.template" ]; then
    envsubst < /etc/shiny-server/template-shiny-server.conf > /etc/shiny-server/shiny-server.conf
fi
