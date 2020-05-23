#!/bin/bash 

# Copy container ENV variables to .Reviron so they will be available to shiny
RENV=/home/shiny/.Renviron
printenv > $RENV