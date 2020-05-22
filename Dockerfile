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

RUN ln /usr/local/lib/shiny-server/shiny-server.sh /usr/bin/shiny-server.sh \
	&& chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]