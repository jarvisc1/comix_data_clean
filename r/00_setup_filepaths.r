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
  dir_data_spss <- '~/../Filr/Net Folders/EPH Shared/Comix_survey/spss_files/spss'
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
}

## AG
if(Sys.info()["nodename"] == "Amys-MacBook-Pro.local"){
  #dir_data_spss <- "data/spss"
  dir_data_spss <- "~/../amygimma/Filr/Net Folders/EPH Shared/Comix_survey/spss_files/spss"
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
}


## KLM
if(Sys.info()["nodename"] == "DESKTOP-R36S69R"){
  #dir_data_spss <- "data/spss"
  dir_data_spss <- 'C:/Users/kw/Filr/Net Folders/EPH Shared/Comix_survey/spss_files/spss'
  ## Filepaths for temp processing files
  dir_data_process <- "data/processing"
}