#!/bin/bash 

if [[ $1 == "--all" || $DEPENDENCY_INSTALL == "ALL" || $DEPENDENCY_INSTALL == "TRUE" || $DEPENDENCY_INSTALL == "true" || $DEPENDENCY_INSTALL == "1" ]] ; then
    DEPENDENCY_INSTALL="ALL" 
fi


if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"protolite"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then  
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libprotobuf-dev protobuf-compiler "
    echo "adding dependencies for protolite"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"magick"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmagick++-dev "
    echo "adding dependencies for magick"
fi;
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"V8"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libv8-dev "
    echo "adding dependencies for V8"
fi 
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"summarytools"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev libgdal-dev tcl8.6-dev tk8.6-dev "
    echo "adding dependencies for summarytools"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"jqr"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libjq-dev "
    echo "adding dependencies for jqr"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"redux"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libhiredis-dev "; 
    echo "adding dependencies for redux"
fi 
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"xml2"* ]] || [[ $REQUIRED_PACKAGES == *"tidyverse"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libxml2-dev "; 
    echo "adding dependencies for xml2"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcairo2-dev libxt-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libsqlite3-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libpq-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssh2-1-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES unixodbc-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcurl4-openssl-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmagick++-dev "; 
    echo "adding dependencies for tba"
fi 
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"shiny"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssl-dev "; 
    echo "adding dependencies for shiny"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"mongolite"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libsasl2-dev "; 
    echo "adding dependencies for mongolite"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"sf"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev default-libmysqlclient-dev libmariadb-dev-compat"; 
    echo "sf"
fi
if [[ $DEPENDENCY_INSTALL == "ALL_CONFLICT" || $REQUIRED_PACKAGES == *"RMySQL"* ]]  && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmariadbclient-dev "; 
    echo "adding dependencies for RMySQL"
fi

## Functionally disabled due to conflicts
if [  1 == 2 ] && [[ $DEPENDENCY_INSTALL == "ALL" || $REQUIRED_PACKAGES == *"zzzzz"* ]] ; then
# libcurl4-gnutls-dev : Conflicts: libcurl4-openssl-dev but 7.68.0-1ubuntu2 is to be installed
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcurl4-gnutls-dev "; 
    echo "adding dependencies for tba"
fi


if [ ! -z "${PACKAGE_DEPENDENCIES}" ] ; then
	echo "installing package dependencies: $PACKAGE_DEPENDENCIES"
	apt-get update -qq && apt-get -y --no-install-recommends install $PACKAGE_DEPENDENCIES

	## clean up install files
	# cd /
	# rm -rf /tmp/*
	# apt-get remove --purge -y $BUILDDEPS
	# apt-get autoremove -y
	# apt-get autoclean -y
	# rm -rf /var/lib/apt/lists/* 
else
	echo "DEPENDENCY_INSTALL != TRUE and REQUIRED_PACKAGES had no packages matching rules so no package dependecies were installed."
fi