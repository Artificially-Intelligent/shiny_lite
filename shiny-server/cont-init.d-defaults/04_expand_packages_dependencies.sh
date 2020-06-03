#!/bin/bash 

# Installs pacakges in ENV variable REQUIRED_PACKAGES and if DISCOVER_PACKAGES=true any packages refrenced in R code in $WWW_DIR

if [ -z "${MRAN}" ];
then
    [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true \
  	&& MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
  	&& echo MRAN=$MRAN >> /etc/environment \
  	&& export MRAN=$MRAN
fi

# Load failed_packages.csv for list of packages that failed to install in a prior call to 06_install_packages.sh
if [[ -f "${SCRIPTS_DIR}/failed_packages.csv" ]] ; then  
    export FAILED_PACKAGES=`cat ${SCRIPTS_DIR}/failed_packages.csv`
fi

if [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then  
 
    # Extract package dependecies for packages in REQUIRED_PACKAGES and/or REQUIRED_PACKAGES_PLUS 
    # and write them to PACKAGES_DEPENDS
    Rscript -e "source('${SCRIPTS_DIR}/expand_package_dependencies.R');"
    if [[ -f "${SCRIPTS_DIR}/package_depends.csv" ]] ; then  
        export PACKAGES_DEPENDS=`cat ${SCRIPTS_DIR}/package_depends.csv`
        echo "Packages identified as dependencies: $PACKAGES_DEPENDS"
    fi
    
fi