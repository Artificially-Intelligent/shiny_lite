list.of.packages <- c(
  "readr",
  "stringr",
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

discover_and_install <- function(default_packages_csv = '/no/file/selected', 
                                 discovery_directory_root = '/srv/shiny-server', 
                                 discovery = FALSE, new_repos = 'https://mran.microsoft.com/'){
  
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
  
  
  old_repos <- getOption("repos")
  options(repos = c( MRAN = new_repos, old_repos))
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
  
  failed_csv <- file.path(Sys.getenv('SCRIPTS_DIR'), 'failed_packages.csv')
  if(file.exists(failed_csv)){
    prev_failed_packages <- unique(unlist(str_split(paste(collapse = ',',unlist(read.csv2(failed_csv, header = FALSE))),",")))
    print(paste("Adding csv entries from",failed_csv ,"to list of packages to install: (", 
                paste(prev_failed_packages, collapse = ",") , ")",sep = ""))
    
    # prev_failed_packages <- unique(str_split(Sys.getenv('FAILED_PACKAGES'),",")[[1]])
    # print(paste("Adding csv entries from ENV variable FAILED_PACKAGES to list of packages to install: (", 
    #             paste(prev_failed_packages, collapse = ",") , ")",sep = ""))
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
        libraries_list <- gsub(' ','',lines[grepl('^library\\(',gsub(' ','',lines))])
        libraries_list <- gsub("'",'',gsub('"','',gsub("\\).*","",libraries_list)))
        libraries_list <- unlist(strsplit(libraries_list, split="[()]"))
        libraries_list <- unique(libraries_list[!grepl('library|;',libraries_list)])
        
        # find packages referenced via :: command
        libraries_list <- c(libraries_list,
                       gsub("\\::.*","",lines[grepl('::',lines)])
        )
        
        # remove anything prior to a , "' character
        libraries_list <- unique(
          gsub(".*\\(","",
               gsub(".*,","",
                    gsub(".* ","",
                         libraries_list
                    )
               )
          )
        )
      }
      
      if(length(libraries_list)>0){
        print(paste("Packages found in", file , "(", paste(libraries_list, collapse = ",") , ")"))
        discovered_packages <- unique(c(libraries_list,discovered_packages))
      }
    }
    print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
  }
  
  install_list <- data.frame(package_name = unique(c(default_packages, required_packages, discovered_packages, prev_failed_packages,required_packages_plus)))
  
  install_list$install_dependencies <- install_list$package_name %in% required_packages_plus
  install_list$verbose <- install_list$package_name %in% prev_failed_packages
  
  install_list <- install_list[! install_list$package_name %in% installed.packages()[,"Package"],]
  
  # packages_to_install <- packages_to_install[!(packages_to_install %in% installed.packages()[,"Package"])]
  
  # shift custom packages to the front of the list
  # packages_to_install <- c(packages_to_install[(packages_to_install %in% c(custom_package_repos$package, custom_package_sources))],
  #                          packages_to_install[! (packages_to_install %in% c(custom_package_repos$package, custom_package_sources))])
  failed_packages <- c()
  if(nrow(install_list)>0){
    print(paste("Packages to be installed (", paste(install_list$package_name, collapse = ",")   , ")" ,sep = ""))
    
    for(i in 1:nrow(install_list)){
      current_package <- install_list[i,]
      current_package_name <- as.character(current_package$package_name)
      if(current_package$install_dependencies){
        current_package_install_dependencies <- TRUE
      }else{
        current_package_install_dependencies <- NA
      }
      
      quiet_install <- ! current_package$verbose
      # quiet_install <- FALSE
      tryCatch(
        {
          
          if(length(current_package_name[!(current_package_name %in% installed.packages()[,"Package"])]) > 0){
            print(paste("Installing package: '", current_package_name , "'" ,sep = ""))
            print(paste("Dependency Options:",paste(current_package_install_dependencies,collapse = ",")))
            
            #checking for custom source
            custom_source <- as.character(custom_package_sources[str_extract(custom_package_sources,  pattern = "\\w+$")  == current_package_name][1])
            custom_repo <- as.character(custom_package_repos$repo[custom_package_repos$package == current_package_name][1])
            
            if(is.na( custom_source) & is.na(custom_repo)){
              print(paste("Source:",paste(getOption('repos'),collapse = ",")))
              install.packages(current_package_name,
                               dependencies = current_package_install_dependencies,
                               # repos = new_repos,
                               # method='wget',
                               quiet = quiet_install
                               )
            }else{
              if(! is.na( custom_source)){
                print(paste("Source: github repo",custom_source))
                devtools::install_github(custom_source)
              }
              if(! is.na( custom_repo)){
                print(paste("Source:", custom_repo))
               install.packages(current_package_name, 
                                 dependencies = current_package_install_dependencies,
                                 repos = custom_repo
                                 # ,
                                 #     method='wget',
                                 # quiet = quiet_install
                                )
              }
            }
            # warnings()
            #write.table(current_package_name, file=installed_packages_csv, row.names=FALSE, col.names=FALSE, sep=",", append = TRUE)
          }else{
            print(paste("Skipping previously installed package: ", current_package_name ,sep = ""))
          }
        }, 
        error=function(cond) {
          failed_packages <- c(failed_packages,current_package_name)
          message(paste("Failed to install:", current_package_name))
          message("Here's the original error message:")
          message(cond)
        }
      )
    }
  }else{
    print("There are no packages to be installed")
  }
  
  installed_packages <- installed.packages()[,"Package"]
  print(paste("Installed packages:",paste(installed_packages,collapse = ",")))
  failed_packages <- install_list$package_name[!install_list$package_name %in% installed_packages]
  
  if(length(failed_packages) > 0){
    print(paste("Packages that failed to install:",paste(failed_packages,collapse = ",")))
    # Write falied package list to file
    write.table(
      paste(failed_packages,collapse = ","),
      sep = ",",
      file = file.path(Sys.getenv('SCRIPTS_DIR'), 'failed_packages.csv'),
      col.names = FALSE,
      row.names = FALSE,
      quote = FALSE
    )
  }
}