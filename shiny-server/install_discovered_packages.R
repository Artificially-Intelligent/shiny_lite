list.of.packages <- c(
  "readr",
  "stringr",
  # "packrat",
  "devtools"
)

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)){
  print(paste('Installing packages needed for package discovery R script:', new.packages, collapse = ' '))
  install.packages(new.packages, quiet = TRUE)
}
library(readr);
library(stringr);
library(devtools);

packrat_snapshot <- function(project = Sys.getenv('WWW_DIR')){
  packrat::snapshot( project = project)
}

discover_and_install <- function(default_packages_csv = '/no/file/selected', 
                                 discovery_directory_root = '/srv/shiny-server', 
                                 discovery = FALSE, repos = 'https://cran.rstudio.com/'){
  
  # list of custom sources to use for remotes::install_github installs
  if(nchar(Sys.getenv('CUSTOM_PACKAGE_SOURCES')) > 0){
    custom_package_sources <- unique(str_split(Sys.getenv('CUSTOM_PACKAGE_SOURCES'),",")[[1]])

    print(paste("Adding csv entries from ENV variable CUSTOM_PACKAGE_SOURCES as list of package source to install from if package requested : (", 
                paste(custom_package_sources, collapse = ",") , ")",sep = ""))
  }else{
    custom_package_sources <- c('jcheng5/bubbles', 'hadley/shinySignals', 'rstudio/httpuv')
  }
  
  # list of custom sources to use for remotes::install_github installs
  if(nchar(Sys.getenv('CUSTOM_PACKAGE_REPOS')) > 0){
    custom_package_repos_raw <- unique(str_split(Sys.getenv('CUSTOM_PACKAGE_REPOS'),",")[[1]])
    
    print(paste("Adding csv entries from ENV variable CUSTOM_PACKAGE_REPOS as list of package source to install from if package requested : (", 
                paste(custom_package_sources, collapse = ",") , ")",sep = ""))
  }else{
    custom_package_repos_raw <- c( "mongolite", 'https://cran.microsoft.com/snapshot/2018-08-01')
  }
  if(length(custom_package_repos_raw) >= 2 &  length(custom_package_repos_raw) %% 2 == 0){
    custom_package_repos <- data.frame(package = custom_package_repos_raw[seq(1,length(custom_package_repos_raw),2)],
                                       repo = custom_package_repos_raw[seq(2,length(custom_package_repos_raw),2)])  
  }else{
    custom_package_repos <- data.frame(package = character(0),
                                       repo = character(0))  
  }
  
  
  
  oldRepos <- getOption("repos")
  options(repos = c( MRAN = repos, oldRepos))
  print(paste("Package Repos:", paste(getOption("repos"), collapse = ",")))
  
  default_packages <- c()
  
  # if(file.exists(default_packages_csv)){
  #   default_packages <- unique(str_split(paste(read.csv2(default_packages_csv,header = FALSE, as.is = TRUE, row.names = NULL, sep = ","), collapse = ","),",")[[1]])
  # }else{
  #   default_packages <- c()
  # }
  
  if(nchar(Sys.getenv('REQUIRED_PACKAGES')) > 0){
    required_packages <- unique(str_split(Sys.getenv('REQUIRED_PACKAGES'),",")[[1]])
    print(paste("Adding csv entries from ENV variable REQUIRED_PACKAGES to list of packages to install: (", 
                paste(required_packages, collapse = ",") , ")",sep = ""))
  }else{
    required_packages <- c()
  }
  
  if(nchar(Sys.getenv('FAILED_PACKAGES')) > 0){
    prev_failed_packages <- unique(str_split(Sys.getenv('FAILED_PACKAGES'),",")[[1]])
    print(paste("Adding csv entries from ENV variable FAILED_PACKAGES to list of packages to install: (", 
                paste(prev_failed_packages, collapse = ",") , ")",sep = ""))
  }else{
    prev_failed_packages <- c()
  }
  
  if(nchar(Sys.getenv('REQUIRED_PACKAGES_PLUS')) > 0){
    required_packages_plus <- unique(c(
      str_split(Sys.getenv('REQUIRED_PACKAGES_PLUS'),",")[[1]]
    ))
    print(paste("Adding csv entries from ENV variable REQUIRED_PACKAGES_PLUS to list of packages to install: (", 
                paste(required_packages_plus, collapse = ",") , ")",sep = ""))
  }else{
    required_packages_plus <- c()
  }
  
  # default_packages_csv_path <- strsplit(default_packages_csv, "/")
  # default_packages_csv_filename <- default_packages_csv_path[[1]][length(default_packages_csv_path[[1]])]
  # installed_packages_csv <- sub(default_packages_csv_filename,'installed_packages.csv',default_packages_csv)
  discovered_packages <- c()
  if(discovery){
    print("Runnning package discovery")
    # packrat::snapshot( project = Sys.getenv('WWW_DIR'))
    
    r_files <- list.files(path = discovery_directory_root, pattern = "*.R$", recursive = TRUE,full.names = TRUE)
    
    print(paste("Scanning", length(r_files), "*.R files found in code directories"))
    
    i <- 0
    for(file in r_files){
      i = i + 1
      #file <- r_files[i]
      print(paste("Scanning", file , "(", i, "/", length(r_files), ")"))
      
      lines <- read_lines(file, skip_empty_rows = TRUE)
      if(length(lines)>0){
        
        # find packages referenced via library() command
        libraries <- gsub(' ','',lines[grepl('^library\\(',gsub(' ','',lines))])
        libraries <- gsub("'",'',gsub('"','',gsub("\\).*","",libraries)))
        libraries <- unlist(strsplit(libraries, split="[()]"))
        libraries <- unique(libraries[!grepl('library|;',libraries)])
        
        # find packages referenced via :: command
        libraries <- c(libraries,
                       gsub("\\::.*","",lines[grepl('::',lines)])
        )
        
        # remove anything prior to a , "' character
        libraries <- unique(
          gsub(".*\\(","",
               gsub(".*,","",
                    gsub(".* ","",
                         libraries
                    )
               )
          )
        )
      }
      
      if(length(libraries)>0){
        print(paste("Packages found in", file , "(", paste(libraries, collapse = ",") , ")"))
        discovered_packages <- unique(c(libraries,discovered_packages))
      }
    }
    print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
  }
  
  packages_to_install <- unique(c(default_packages, required_packages, discovered_packages, prev_failed_packages))
  if(length(packages_to_install)>0){
    install_list <- data.frame(package_name = packages_to_install,
                               install_dependencies = FALSE)
  }else{
    install_list <- data.frame(package_name = character(0),
               install_dependencies = character(0))
    
  }
  if(length(required_packages_plus) > 0){
    install_list <- rbind(install_list,
                          data.frame(package_name = required_packages_plus,
                               install_dependencies = TRUE)
    )
  }
  
  
  install_list <- install_list[! install_list$package_name %in% installed.packages()[,"Package"],]
                        
  # packages_to_install <- packages_to_install[!(packages_to_install %in% installed.packages()[,"Package"])]
  
  # shift custom packages to the front of the list
  # packages_to_install <- c(packages_to_install[(packages_to_install %in% c(custom_package_repos$package, custom_package_sources))],
  #                          packages_to_install[! (packages_to_install %in% c(custom_package_repos$package, custom_package_sources))])
  failed_packages <- c()
  if(length(install_list)>0){
    print(paste("Packages to be installed (", paste(packages_to_install, collapse = ",")   , ")" ,sep = ""))
    
    for(i in 1:nrow(install_list)){
      package <- install_list[i,]
      package_name <- package$package_name
      install_dependencies <- package$install_dependencies
      tryCatch(
        {
          
          if(length(package_name[!(package_name %in% installed.packages()[,"Package"])]) > 0){
            print(paste("Installing package: ", package_name ,sep = ""))
            #checking for custom source
            custom_source <- custom_package_sources[str_extract(custom_package_sources,  pattern = "\\w+$")  == package_name][1]
            custom_repo <- custom_package_repos$repo[custom_package_repos$package == package_name][1]
            
            if(is.na( custom_source) & is.na(custom_repo)){
            install.packages(package_name, 
                             dependencies = install_dependencies,
                             repos = repos,
                             #     method='wget',
                             quiet = TRUE)
            }else{
              if(! is.na( custom_source))
                devtools::install_github(custom_source)
              if(! is.na( custom_repo))
                install.packages(package_name, 
                                 dependencies = install_dependencies,
                                 repos = custom_repo,
                                 #     method='wget',
                                 quiet = TRUE)
            }
            warnings()
            #write.table(package_name, file=installed_packages_csv, row.names=FALSE, col.names=FALSE, sep=",", append = TRUE)
          }else{
            print(paste("Skipping previously installed package: ", package_name ,sep = ""))
          }
        }, 
        error=function(cond) {
          failed_packages <- c(failed_packages,package_name)
          message(paste("Failed to install:", package_name))
          message("Here's the original error message:")
          message(cond)
        }
        
      )
    }
  }else{
    print("There are no packages to be installed")
  }
  print(paste("Installed packages:",paste(installed.packages()[,"Package"],collapse = ",")))
  if(length(failed_packages) > 0){
    print(paste("Packages that failed to install:",paste(failed_packages,collapse = ",")))
    # Write falied package list to file
    write.table(
      depends_csv,
      sep = ",",
      file = file.path(Sys.getenv('SCRIPTS_DIR'), 'failed_packages.csv'),
      col.names = FALSE,
      row.names = FALSE,
      quote = FALSE
    )
  }
}

discover_and_install()
