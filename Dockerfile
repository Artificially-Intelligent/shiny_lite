# Base image https://hub.docker.com/u/rocker/
ARG SOURCE_TAG=latest
ARG SOURCE_IMAGE=rocker/shiny
FROM $SOURCE_IMAGE:$SOURCE_TAG

ARG $SOURCE_REPO
ARG $SOURCE_BRANCH
ARG $SOURCE_COMMIT

ENV SOURCE_REPO=$SOURCE_REPO
ENV SOURCE_BRANCH=$SOURCE_BRANCH
ENV SOURCE_COMMIT=$SOURCE_COMMIT


RUN apt-get update && apt-get install -y \
	git  \
	## clean up install files
	&& cd / \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* 


ADD scripts /usr/local/lib/shiny-server

## create directories for mounting shiny app code / data
ARG PARENT_DIR=/srv/shiny-server
ARG DATA_DIR=${PARENT_DIR}/data
ARG WWW_DIR=${PARENT_DIR}/www
ARG TEMP_DIR=${PARENT_DIR}/staging
ARG OUTPUT_DIR=${PARENT_DIR}/output
ARG LOG_DIR=/var/log/shiny-server

RUN mkdir -p $PARENT_DIR \
	&& mkdir -p $DATA_DIR \
 	&& mkdir -p $WWW_DIR \
 	&& ln -s /tmp $TEMP_DIR \
 	&& mkdir -p $OUTPUT_DIR \
 	&& mkdir -p $LOG_DIR \
	&& chown $PUID.$PGID -R $PARENT_DIR 

## start shiny server
ENV REQUIRED_PACKAGES ${REQUIRED_PACKAGES}

ENV DATA_DIR ${DATA_DIR}
ENV WWW_DIR ${WWW_DIR}
ENV TEMP_DIR ${TEMP_DIR}
ENV OUTPUT_DIR ${OUTPUT_DIR}
ENV LOG_DIR ${LOG_DIR} 

RUN ln /usr/local/lib/shiny-server/shiny-server.sh /usr/bin/shiny-server.sh \
	&& chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]