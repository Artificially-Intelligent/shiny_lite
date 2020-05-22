# Base image https://hub.docker.com/u/rocker/
ARG SOURCE_TAG=latest
ARG SOURCE_IMAGE=rocker/shiny
FROM $SOURCE_IMAGE:$SOURCE_TAG

COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
ADD cont-init.d-defaults /etc/shiny-server/

RUN chmod +x /usr/bin/shiny-server.sh 

CMD ["/usr/bin/shiny-server.sh"]