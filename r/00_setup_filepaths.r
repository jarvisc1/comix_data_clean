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
  parent_path <- '~/../Filr/Net Folders/EPH Shared/Comix_survey'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('../comix/data/')
}

## AG
if(Sys.info()["nodename"] == "Amys-MacBook-Pro.local"){
  parent_path <- '~/../amygimma/Filr/Net Folders/EPH Shared/Comix_survey'
  dir_data_spss <- file.path(parent_path,'data/spss')
  #dir_data_spss <- "data/spss"
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('data', "clean")
  
  pw_file_path <- "data/sharing/pw_secret.R"
}


## KLM
if(Sys.info()["nodename"] == "DESKTOP-R36S69R"){
  #dir_data_spss <- "data/spss"
  parent_path <- 'C:/Users/kw/Filr/Net Folders/EPH Shared/Comix_survey'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('data/')
}

## PC
if(Sys.info()["nodename"] == "pietro-XPS-15-9550"){
  #dir_data_spss <- "data/spss"
  parent_path <- '/home/pietro/calcolo/COVID-19/comix_data_clean'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('data/')
}

## JW
if(Sys.info()["nodename"] == "LP10494-01"){
  #dir_data_spss <- "data/spss"
  parent_path <- 'C:/Users/lucp10494/Desktop/COVID-19 FOLDER/COVID-19 COMIX ANALYSIS FOLDER/COMIX IPSOS DATA CLEANING/comix_data_clean'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('data/')
}


## LB
if(Sys.info()["nodename"] == "RIVM-SF1-0196"){
  #dir_data_spss <- "data/spss"
  parent_path <- 'N:/2020 CoMixNL/comix_data_clean'
  dir_data_spss <- file.path(parent_path, 'data/spss')
  dir_data_clean <- file.path(parent_path, 'data/clean')
  dir_data_archive <- file.path(parent_path, 'data/clean/archive')
  dir_data_validate <- file.path(parent_path, 'data/validated')
  dir_data_valid_archive <- file.path(parent_path, 'data/validated/archive')
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
  dir_data_local <- file.path('data/')
}
