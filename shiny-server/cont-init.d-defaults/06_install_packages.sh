#!/bin/bash

# Installs pacakges in ENV variable REQUIRED_PACKAGES and if DISCOVER_PACKAGES=true any packages refrenced in R code in $WWW_DIR

if [ -z "${MRAN}" ];
then
    [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true \
  	&& MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
  	&& echo MRAN=$MRAN >> /etc/environment \
  	&& export MRAN=$MRAN
fi

    echo "Installing R packages using repository: $MRAN"
    echo "REQUIRED_PACKAGES: $REQUIRED_PACKAGES"
    echo "REQUIRED_PACKAGES_PLUS: $REQUIRED_PACKAGES_PLUS"

# install rstudion/httpuv to enable compatibility with google cloud run https://github.com/rstudio/shiny/issues/2455
# Rscript -e "if(! 'httpuv' %in% c( installed.packages()[,'Package'])) remotes::install_github(c('rstudio/httpuv'))"

# if [[ $REQUIRED_PACKAGES_PLUS == *"mongolite"* || $REQUIRED_PACKAGES == *"mongolite"* ]] ; then
# 	## Old version of mongolite required for wire protocol 2 to support Azure Cosmos DB connections
# 	apt-get update -qq && apt-get -y install libsasl2-dev
# 	Rscript -e "if(! 'mongolite' %in% c( installed.packages()[,'Package'])) install.packages('mongolite', repos = 'https://cran.microsoft.com/snapshot/2018-08-01')"
# fi

if [[ -f "${SCRIPTS_DIR}/failed_packages.csv" ]] ; then  
    export FAILED_PACKAGES=`cat ${SCRIPTS_DIR}/failed_packages.csv`
fi

if [ "$DISCOVER_PACKAGES" = "true" ] || [ "$DISCOVER_PACKAGES" = "TRUE" ] || [ "$DISCOVER_PACKAGES" = "1" ];
then
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
    # or those discovered  by a scan of files in $WWW_DIR looking for library('packagename') entries
	echo 
	Rscript -e "source('${SCRIPTS_DIR}/install_discovered_packages.R'); discover_and_install(default_packages_csv = '${SCRIPTS_DIR}/default_install_packages.csv', discovery_directory_root = '$WWW_DIR', discovery = TRUE, new_repos='$MRAN');"
else
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
	Rscript -e "source('${SCRIPTS_DIR}/install_discovered_packages.R'); discover_and_install(default_packages_csv = '${SCRIPTS_DIR}/default_install_packages.csv', discovery_directory_root = '$WWW_DIR', discovery = FALSE, new_repos='$MRAN');"
fi