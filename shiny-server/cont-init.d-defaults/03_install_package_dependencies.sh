#!/bin/bash 

if [[ $1 == "--all" || $DEPENDENCY_INSTALL == "ALL" || $DEPENDENCY_INSTALL == "TRUE" || $DEPENDENCY_INSTALL == "true" || $DEPENDENCY_INSTALL == "1" ]] ; then
    DEPENDENCY_INSTALL="ALL" 
fi

ALL_REQUIRED_PACKAGES=",$REQUIRED_PACKAGES,$REQUIRED_PACKAGES_PLUS,$FAILED_PACKAGES,"

if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",protolite,"* || $ALL_REQUIRED_PACKAGES == *",geojson,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then  
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libprotobuf-dev protobuf-compiler "
    echo "adding dependencies for protolite"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",magick,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmagick++-dev "
    echo "adding dependencies for magick"
fi;
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",V8,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libnode-dev libv8-dev "
    echo "adding dependencies for V8"
fi 
if [[ $DEPENDENCY_INSTALL == "TOO BIG FOR ALL" || $ALL_REQUIRED_PACKAGES == *",summarytools,"*  || $ALL_REQUIRED_PACKAGES == *",sf,"*  || $ALL_REQUIRED_PACKAGES == *",units,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libgdal-dev "
    echo "adding dependencies for summarytools / sf"
fi

if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",summarytools,"*  || $ALL_REQUIRED_PACKAGES == *",sf,"*  || $ALL_REQUIRED_PACKAGES == *",units,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES tcl8.6-dev tk8.6-dev "
    echo "adding dependencies for summarytools / sf"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",summarytools,"*  || $ALL_REQUIRED_PACKAGES == *",units,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev "
    echo "adding dependencies for units"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",jqr,"* || $ALL_REQUIRED_PACKAGES == *",geojson,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libjq-dev "
    echo "adding dependencies for jqr"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",redux,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libhiredis-dev "; 
    echo "adding dependencies for redux"
fi 
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",xml2,"* ]] || [[ $ALL_REQUIRED_PACKAGES == *",tidyverse,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libxml2-dev "; 
    echo "adding dependencies for xml2"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",hrbrthemes,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcairo2-dev libxt-dev libfontconfig1-dev "; 
    echo "adding dependencies for hrbrthemes"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libsqlite3-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",sf,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libpq-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssh2-1-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES unixodbc-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcurl4-openssl-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmagick++-dev "; 
    echo "adding dependencies for tba"
fi 
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",shiny,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssl-dev "; 
    echo "adding dependencies for shiny"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",mongolite,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libsasl2-dev "; 
    echo "adding dependencies for mongolite"
fi
if [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",sf,"* ]] && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev default-libmysqlclient-dev libmariadb-dev-compat"; 
    echo "sf"
fi
if [[ $DEPENDENCY_INSTALL == "ALL_CONFLICT" || $ALL_REQUIRED_PACKAGES == *",RMySQL,"* ]]  && [[ $DEPENDENCY_INSTALL != "NONE" ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmariadbclient-dev-compat libmariadbclient-dev "; 
    echo "adding dependencies for RMySQL"
fi

## Functionally disabled due to conflicts
if [  1 == 2 ] && [[ $DEPENDENCY_INSTALL == "ALL" || $ALL_REQUIRED_PACKAGES == *",zzzzz,"* ]] ; then
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
	echo "DEPENDENCY_INSTALL != TRUE and ALL_REQUIRED_PACKAGES had no packages matching rules so no package dependecies were installed."
fi