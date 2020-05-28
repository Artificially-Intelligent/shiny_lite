# Base image https://hub.docker.com/u/rocker/
ARG SOURCE_TAG=latest
ARG SOURCE_IMAGE=rocker/shiny
FROM $SOURCE_IMAGE:$SOURCE_TAG

ARG $SOURCE_REPO
ARG $SOURCE_BRANCH
ARG $SOURCE_COMMIT

ENV SOURCE_DOCKER_IMAGE=$SOURCE_IMAGE:$SOURCE_TAG
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

ARG SHINY_DIR=/srv/shiny-server
ENV WWW_DIR ${SHINY_DIR}
ENV LOG_DIR /var/log/shiny-server
ENV LIB_DIR=/usr/local/lib/shiny-server

RUN rm -r $SHINY_DIR \
	&& rm /etc/shiny-server/* \
	&& mkdir -p $WWW_DIR \
 	&& mkdir -p $LOG_DIR \
	&& chown $PUID.$PGID -R $SHINY_DIR

## install package dependcies
# DISCOVERY=TRUE to try and discover packages required you code in $WWW_DIR
ARG DISCOVERY=FALSE
# CSV list of packages
ARG PACKAGES=
ARG PACKAGES_PLUS=
# DEPENDENCY=TRUE to install all know package dependcies 
ARG DEPENDENCY=

ENV DISCOVER_PACKAGES ${DISCOVER}
ENV REQUIRED_PACKAGES ${PACKAGES}
ENV REQUIRED_PACKAGES_PLUS ${PACKAGES_PLUS}
ENV DEPENDENCY_INSTALL ${DEPENDENCY}

RUN chmod +x ${LIB_DIR}/cont-init.d-defaults/* \ 
	&& ${LIB_DIR}/cont-init.d-defaults/03_install_package_dependencies.sh \
	&& ${LIB_DIR}/cont-init.d-defaults/04_install_packages.sh

## start shiny server
RUN ln -f ${LIB_DIR}/shiny-server.sh /usr/bin/shiny-server.sh \
	&& chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]