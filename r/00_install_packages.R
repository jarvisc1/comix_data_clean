## Packages

## Here we record all the packages used in the analyses

pkgs <- c(
  "data.table",
  "qs",
  "stringr",
  "lubridate",
  "readxl"
  )

install.packages(setdiff(pkgs, rownames(installed.packages())), 
                 repos="https://cran.ma.imperial.ac.uk/")
