## Name: 00_setup_filepaths
## Description: Set filepaths for accessing the data
## Input file: 
## Functions: 
## Output file: 

## If you are a new user of the data you need to download LSHTM filesharing and get
## access to the LSHTM Comix data folders


# Setup filepaths ---------------------------------------------------------

## Filepaths for origin of spss files
## CIJ
if(Sys.info()["nodename"] == "DESKTOP-OKJFGKO"){
  #dir_data_spss <- "data/spss"
  parent_path <- '~/../Filr/Net Folders/EPH Shared/Comix_survey/new_do_not_remove'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('../comix/data/')
}

## AG
if(Sys.info()["nodename"] == "Amys-MacBook-Pro.local"){
  parent_path <- '~/../amygimma/Filr/Net Folders/EPH Shared/Comix_survey/new_do_not_remove'
  dir_data_spss <- file.path(parent_path,'data/spss')
  #dir_data_spss <- "data/spss"
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  ## Filepaths for temp processing files
  dir_data_process <- file.path("data", "processing")
  dir_data_local <- file.path('data', "processing")
  
}


## KLM
if(Sys.info()["nodename"] == "DESKTOP-R36S69R"){
  #dir_data_spss <- "data/spss"
  parent_path <- 'C:/Users/kw/Filr/Net Folders/EPH Shared/Comix_survey/new_do_not_remove'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
}