list.of.packages <- c("stringr")
new.packages <-
  list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  print(
    paste(
      'Installing packages needed for package discovery R script:',
      new.packages,
      collapse = ' '
    )
  )
  install.packages(new.packages, quiet = TRUE)
}
library(stringr)


# Add snapshot repos
repos <- Sys.getenv('MRAN')
oldRepos <- getOption('repos')
combined_repos <- c(MRAN = repos, oldRepos)
combined_repos <- combined_repos[nchar(combined_repos) > 0]
options(repos = combined_repos)
print(paste('Package Repos:', paste(getOption('repos'), collapse = ',')))

# Load available packages
package_list <-
  unique(c(
    Sys.getenv('FAILED_PACKAGES'),
    Sys.getenv('REQUIRED_PACKAGES'),
    Sys.getenv('REQUIRED_PACKAGES_PLUS')
  ))

package_list <- package_list[nchar(package_list) > 0]
if (length(package_list) > 0) {
  pack <- available.packages()
  package_list <- package_list[package_list %in% pack[, 'Package']]
  
  # Extract dependencies for package list
  depends <-
    str_extract(unlist(str_split(pack[package_list, 'Depends'], ',')), pattern = '\\w+')
  depends <- depends[!depends == 'R']
  imports <-
    str_extract(unlist(str_split(pack[package_list, 'Imports'], ',')), pattern = '\\w+')
  depends_csv <- paste(unique(c(depends, imports)), collapse = ',')
} else{
  depends_csv <- ""
}
write.table(
  depends_csv,
  sep = ",",
  file = file.path(Sys.getenv('SCRIPTS_DIR'), 'package_depends.csv'),
  col.names = FALSE,
  row.names = FALSE,
  quote = FALSE
)
