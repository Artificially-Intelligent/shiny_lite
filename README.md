# [Artificially-Intelligent/Shiny_Lite](https://github.com/Artificially-Intelligent/shiny_lite)

## Description
rocker/shiny docker image with modified startup script that allows for more config options an the inclusion of other scripts in the container startup sequence. By default the startup scripts included include prerequistes required by several r packages.  

## Usage

Here are some example snippets to help you get started creating a container.

## docker

```
docker create \
  --name=myshinyapp \
  -p 8080:8080 \
  -e SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples \
  -e PORT=8080 \
  -e SHINY_APP_INIT_TIMEOUT=60 \
  -e SHINY_APP_IDLE_TIMEOUT=5 \
  -e SHINY_DISABLE_PROTOCOLS="websocket xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile xdr-polling iframe-xhr-polling" \
  -e SHINY_GOOGLE_ANALYTICS_ID="UA-12345-1" \
  -e MRAN=https://mran.microsoft.com/snapshot/2020-05-22 \
  -e APPLICATION_LOGS_TO_STDOUT=FALSE \
  -e DISCOVER_PACKAGES=TRUE \
  -v path/to/config_scripts:/etc/cont-init.d \
  -v path/to/code:/srv/shiny-server \
  -v path/to/log_output:/var/log/shiny-server \
  --restart unless-stopped \
  artificiallyintelligent/shiny_lite
```

## docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  shiny:
    image: artificiallyintelligent/shiny_lite
    container_name: myshinyapp
    environment:
      - DISCOVER_PACKAGES=true
      - SHINY_APP_IDLE_TIMEOUT=5
      - SHINY_APP_INIT_TIMEOUT=60
      - SHINY_GOOGLE_ANALYTICS_ID="UA-12345-1"
      - PORT=8080
      - SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples
      - K_REVISION=set_any_value
      - MRAN=https://mran.microsoft.com/snapshot/2020-05-22
      - APPLICATION_LOGS_TO_STDOUT=FALSE
    volumes:
      - path/to/config_scripts:/etc/cont-init.d
      - path/to/code:/srv/shiny-server
      - path/to/log_output:/var/log/shiny-server
    ports:
      - 3838:8080
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3838:8080` | Specify a port mapping from container to host for shiny server web ui. Port value after the : should match that defined by PORT environment variable or the default value 8080 |
| `-e PORT=8080` | Specify a port for shiny to use inside the container. Included to support deployment to google cloud run. If not set default value is 8080 |
| `-e SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples` | Specifiy a url for a github repo to copy to code directory at container runtime. Note only supports https, not ssh. Private repo can be added by including an access token in the url eg. https://myaccesstoken@github.com/mygithubuser/mygithubrepo.git | 
| `-e PRIVILEGED=false` | Set true to run shiny-server as root user  |
| `-e DISCOVER_PACKAGES=true` | Set true to have  *.R files in /code & /02_code directories + subdirectories scanned for library(package) entries. Missing R packages will be installed as part of container startup. |
| `-e REQUIRED_PACKAGES=packages,to,install` | Specify a csv list of R package names to look for ensure are installed irrespective of if package discovery is on and/or finds a library() refrence for them. |
| `-e DEPENDENCY_INSTALL=ALL` | Set ALL to have all package dependencies rules run. Dependencies will also be installed is a package matching a rule is found in REQUIRED_PACKAGES |
| `-v .:/srv/shiny-server` | The web root for shiny. R shiny code resides here. |
| `-e WWW_DIR=/srv/shiny-server` | Specify a custom location for shiny www root directory inside container. | 
| `-e K_REVISION` | If set with any value container presumes Google Cloud Run Host. Disables incompatible protocols by setting SHINY_DISABLE_PROTOCOLS="websocket xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile xdr-polling iframe-xhr-polling" | 
| `-e SHINY_DISABLE_PROTOCOLS` | If /etc/shiny-server/template-shiny-server.conf exists, passes value in shiny config via envsubst overwriting /etc/shiny-server/shiny-server.conf . Disables shiny protocols, see disable_protocols in shiny documentation for details. https://docs.rstudio.com/shiny-server/#disabling-websockets-on-the-server | 
| `-e SHINY_APP_IDLE_TIMEOUT=5` | Specify a app_idle_timeout to use when starting shiny server. Default value is 5, boosting to 1800 helps prevent session disconnects. See app_idle_timeout in shiny documentation for details. http://docs.rstudio.com/shiny-server/#application-timeouts |
| `-e SHINY_APP_INIT_TIMEOUT=60` | Specify a app_init_timeout to use when starting shiny server. Default value is 60, boosting to 1800 helps prevent session disconnects. See app_init_timeout in shiny documentation for details. http://docs.rstudio.com/shiny-server/#application-timeouts |
| `-e SHINY_GOOGLE_ANALYTICS_ID=UA-12345-1` | Specify a google_analytics_id for shiny to enable Google Analytics tracking globally. See app_init_timeout in shiny documentation for details. https://docs.rstudio.com/shiny-server/#google-analytics |

## Preinstalled Packages

## Deploying to Google Cloud Run
Look at instructions here for the general process of how to:
+ Deloy container image to Google Container Registry: https://cloud.google.com/run/docs/deploying
+ Deloy Container Registry image as a Google Cloud Run service: https://cloud.google.com/run/docs/deploying

## Troubleshooting

Run package, start shiny-server and view logs
  ```
  docker run -it -p 3838:3838 -e PORT=3838 --name shiny artificiallyintelligent/shiny:latest /bin/bash
  ```
  ```
  setsid /usr/bin/srv/shiny-server.sh >/dev/null 2>&1 < /dev/null &
  cat /var/log/srv/shiny-server/code-shiny-*
  ```

Check if there is sufficient disc space available for temp files
  ```
  df -h /tmp
  ```
