#!/bin/bash

if [ -z "${SHINY_APP_INIT_TIMEOUT}" ]; then
    echo "SHINY_APP_INIT_TIMEOUT not specified, shiny server run using default value: 60"
    if [ -z "${APP_INIT_TIMEOUT}" ]; then
        export SHINY_APP_INIT_TIMEOUT=60
    else
        export SHINY_APP_INIT_TIMEOUT=$APP_INIT_TIMEOUT
    fi
fi

if [ -z "${SHINY_APP_IDLE_TIMEOUT}" ]; then
    echo "SHINY_APP_IDLE_TIMEOUT not specified, shiny server run using default value: 5"
    if [ -z "${APP_IDLE_TIMEOUT}" ]; then
        export SHINY_APP_IDLE_TIMEOUT=5
    else
        export SHINY_APP_IDLE_TIMEOUT=$APP_IDLE_TIMEOUT
    fi
fi

export SHINY_GOOGLE_ANALYTICS_CONFIG_ENTRY=
if [ ! -z "${SHINY_GOOGLE_ANALYTICS_ID}" ]; then
    echo "SHINY_GOOGLE_ANALYTICS_ID specified, enabling google analytics globally using id: $SHINY_GOOGLE_ANALYTICS_ID"
    export SHINY_GOOGLE_ANALYTICS_CONFIG_ENTRY="google_analytics_id \"${SHINY_GOOGLE_ANALYTICS_ID}\";"
fi

# if running in google cloud run disable incompatible protocols
if [ ! -z "${K_REVISION}" ];
then
    # remaining active protocols: jsonp-polling xhr-polling 
    export SHINY_DISABLE_PROTOCOLS="websocket xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile xdr-polling iframe-xhr-polling"
    echo "K_REVISION ENV Variable set with value '$K_REVISION'. Presuming Google Cloud Run Host, disabling incompatible protocols for shiny server: $SHINY_DISABLE_PROTOCOLS"
fi

#Substitute ENV variable values into template-shiny-server.conf and overwrite shiny-server.conf
if [ -f  "/etc/shiny-server/template-shiny-server.conf" ]; then
    echo "overwriting shiny-server.conf with template-shiny-server.conf and ENV variables"
    envsubst < /etc/shiny-server/template-shiny-server.conf > /etc/shiny-server/shiny-server.conf
fi
