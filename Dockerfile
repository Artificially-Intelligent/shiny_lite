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
    libxt-dev \
    xtail \
    wget \
 	gosu \
	gettext-base \
	git  \
	## clean up install files
	&& cd / \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* 

ADD shiny-server /usr/local/lib/shiny-server

## create directories for mounting shiny app code / data
ARG PARENT_DIR=/srv/shiny-server
ARG WWW_DIR=${PARENT_DIR}
# ARG DATA_DIR=${PARENT_DIR}/data
# ARG WWW_DIR=${PARENT_DIR}/www
# ARG TEMP_DIR=${PARENT_DIR}/staging
# ARG OUTPUT_DIR=${PARENT_DIR}/output
ARG LOG_DIR=/var/log/shiny-server

RUN rm -r $PARENT_DIR \
	&& rm /etc/shiny-server/* \
	&& mkdir -p $PARENT_DIR \
 	&& mkdir -p $WWW_DIR \
 	&& mkdir -p $LOG_DIR \
	&& chown $PUID.$PGID -R $PARENT_DIR


ENV WWW_DIR ${WWW_DIR}
ENV LOG_DIR ${LOG_DIR} 
ENV LIB_DIR=/usr/local/lib/shiny-server


## install package dependcies
ARG DISCOVER_PACKAGES=FALSE
ARG REQUIRED_PACKAGES=
ARG DEPENDENCY_INSTALL=

ENV DISCOVER_PACKAGES ${DISCOVER_PACKAGES}
ENV REQUIRED_PACKAGES ${REQUIRED_PACKAGES}
ENV DEPENDENCY_INSTALL ${DEPENDENCY_INSTALL}

RUN chmod +x ${LIB_DIR}/cont-init.d-defaults/* \ 
	&& ${LIB_DIR}/cont-init.d-defaults/03_install_package_dependencies.sh \
	&& ${LIB_DIR}/cont-init.d-defaults/04_install_packages.sh

## start shiny server
RUN ln -f ${LIB_DIR}/shiny-server.sh /usr/bin/shiny-server.sh \
	&& chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]