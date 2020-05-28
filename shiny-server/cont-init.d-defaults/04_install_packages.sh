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


if [[ $REQUIRED_PACKAGES_PLUS == *"mongolite"* || $REQUIRED_PACKAGES == *"mongolite"* ]] ; then
	## Old version required for Azure connections
	apt-get update -qq && apt-get -y install libsasl2-dev
	Rscript -e "install.packages('mongolite', repos = 'https://cran.microsoft.com/snapshot/2018-08-01')"
fi

if [ "$DISCOVER_PACKAGES" = "true" ] || [ "$DISCOVER_PACKAGES" = "TRUE" ] || [ "$DISCOVER_PACKAGES" = "1" ];
then
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
    # or those discovered  by a scan of files in $WWW_DIR looking for library('packagename') entries
	echo 
	Rscript -e "source('${LIB_DIR}/install_discovered_packages.R'); discover_and_install(default_packages_csv = '${LIB_DIR}/default_install_packages.csv', discovery_directory_root = '$WWW_DIR', discovery = TRUE,repos='$MRAN');"
else
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
	Rscript -e "source('${LIB_DIR}/install_discovered_packages.R'); discover_and_install(default_packages_csv = '${LIB_DIR}/default_install_packages.csv', discovery_directory_root = '$WWW_DIR', discovery = FALSE,repos='$MRAN');"
fi