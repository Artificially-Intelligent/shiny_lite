# Base image https://hub.docker.com/u/rocker/
ARG SOURCE_TAG=latest
ARG SOURCE_IMAGE=rocker/shiny
FROM $SOURCE_IMAGE:$SOURCE_TAG

RUN mkdir -p /etc/cont-init.d/
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY install_package_dependencies.sh /etc/cont-init.d/install_package_dependencies.sh
RUN chmod +x /usr/bin/shiny-server.sh \
	&& chmod +700 -R /etc/cont-init.d

CMD ["/usr/bin/shiny-server.sh"]