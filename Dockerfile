# Base image https://hub.docker.com/u/rocker/
ARG SRC_TAG=latest
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

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    chown shiny:shiny /var/lib/shiny-server \
	## clean up install files
	&& cd / \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* 

# Download and install R packages and suggested dependencies from csv ENV variable REQUIRED_PACKAGES_PLUS
RUN install2.r \
	--error \
    --deps TRUE \
    --skipinstalled \
	--ncpus -1 \
	shiny \
	rmarkdown \
	remotes \
#	`echo $REQUIRED_PACKAGES_PLUS |  sed 's/,/ /g'` \
	&& rm -rf /tmp/*


ARG BLD_DATE
ARG VERSION=0.x.x
ARG MAINTAINER=slink42
ARG $SRC_REPO
ARG $SRC_BRANCH
ARG $SRC_COMMIT
ARG $DEST_IMAGE

ENV SOURCE_DOCKER_IMAGE=$SRC_IMAGE:$SRC_TAG
ENV SOURCE_REPO=${$SRC_REPO}
ENV SOURCE_BRANCH=${$SRC_BRANCH}
ENV SOURCE_COMMIT=${$SRC_COMMIT}
ENV DOCKER_IMAGE=${$DEST_IMAGE}
ENV BUILD_DATE=${BLD_DATE}

# add image labels
LABEL build_version="$DOCKER_IMAGE version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL build_source="$SOURCE_BRANCH - https://github.com/Artificially-Intelligent/shiny_lite/commit/${SOURCE_COMMIT}"
LABEL maintainer="$MAINTAINER"

# add shiny server custom scripts
ADD shiny-server /usr/local/lib/shiny-server

## create directories for mounting shiny app code
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