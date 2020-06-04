# Base image https://hub.docker.com/u/rocker/
ARG SRC_TAG=3.6.3
ARG SRC_IMAGE=rocker/r-ver
FROM $SRC_IMAGE:$SRC_TAG

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
	xtail \
    wget \
 	gosu \
	gettext-base \
	git

## Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt) ; export VERSION && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    chown shiny:shiny /var/lib/shiny-server
 
 ## Download and install major r packages
 RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libmariadbclient-dev \
    libpq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libssh2-1-dev \
    unixodbc-dev \
	&& install2.r \
		--error \
		--deps TRUE \
		--skipinstalled \
		--ncpus -1 \
		shiny \
		rmarkdown \
        devtools \
        readr \
        stringr \
	&& rm -rf /tmp/downloaded_packages

ARG BLD_DATE
ARG MAINTAINER=slink42
ARG SRC_REPO=Artificially-Intelligent/shiny_lite
ARG SRC_BRANCH=master
ARG SRC_COMMIT=XXXXXXXX
ARG DEST_IMAGE="ArtificiallyIntelligent/shiny_lite"

ENV SOURCE_DOCKER_IMAGE=$SRC_IMAGE:$SRC_TAG
ENV SOURCE_REPO=$SRC_REPO
ENV SOURCE_BRANCH=$SRC_BRANCH
ENV SOURCE_COMMIT=$SRC_COMMIT
ENV DOCKER_IMAGE=$DEST_IMAGE
ENV SHINY_BUILD_DATE=$BLD_DATE

# add image labels
LABEL build_version="$DOCKER_IMAGE version:- ${VERSION} Build-date:- ${SHINY_BUILD_DATE}"
LABEL build_source="$SOURCE_BRANCH - https://github.com/${SOURCE_REPO}/commit/${SOURCE_COMMIT}"
LABEL maintainer="$MAINTAINER"



## create directories for mounting shiny app code
ARG SHINY_DIR=/srv/shiny-server
ENV WWW_DIR=$SHINY_DIR
ENV LOG_DIR=/var/log/shiny-server
ENV SCRIPTS_DIR=/usr/local/lib/shiny-server
ENV PUID=shiny
ENV PGID=shiny

RUN rm -r $WWW_DIR \
	&& rm /etc/shiny-server/* \
	&& mkdir -p $WWW_DIR \
 	&& mkdir -p $LOG_DIR \
	&& mkdir -p $SCRIPTS_DIR \
	&& chown $PUID.$PGID -R $WWW_DIR \
	&& chown $PUID.$PGID -R $SCRIPTS_DIR \
	&& chown $PUID.$PGID -R $LOG_DIR

# add shiny server custom scripts
ADD shiny-server $SCRIPTS_DIR

## install package dependcies
# DISCOVERY=TRUE to try and discover packages required you code in $WWW_DIR
ARG DISCOVERY=FALSE
# CSV list of packages
ARG PACKAGES=
ARG PACKAGES_PLUS=
# DEPENDENCY=TRUE to install all know package dependencies 
# DEPENDENCY=NONE to prevent all package dependency install rules
ARG DEPENDENCY=FALSE

ENV DISCOVER_PACKAGES=$DISCOVER
ENV REQUIRED_PACKAGES=$PACKAGES
ENV REQUIRED_PACKAGES_PLUS=$PACKAGES_PLUS
ENV DEPENDENCY_INSTALL=$DEPENDENCY

RUN chmod +x ${SCRIPTS_DIR}/cont-init.d-defaults/* \ 
	&& ${SCRIPTS_DIR}/cont-init.d-defaults/04_expand_packages_dependencies.sh \
	&& ${SCRIPTS_DIR}/cont-init.d-defaults/05_install_package_dependencies.sh \
	&& ${SCRIPTS_DIR}/cont-init.d-defaults/06_install_packages.sh

## start shiny server
RUN ln -f ${SCRIPTS_DIR}/shiny-server.sh /usr/bin/shiny-server.sh \
	&& chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]