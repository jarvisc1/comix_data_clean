## Name: dm04_rename_vars_v5.R
## Description: Rename the variables using a csv file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## Functions: 
## Output file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## NOTE: !Need to sort out so only one change names function

# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("group")) group <- "Group1"
if(length(args) == 1) group <- args
print(group)
# Setup input and output data and filepaths -------------------------------
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = group)
filenames <- filenames[!is.na(filenames$spss_name) & 
                         filenames$survey_version == 5,]
r_names <- filenames$r_name

# Load dataname spreadsheet -----------------------------------------------
survey5 <- as.data.table(readxl::read_excel("codebook/var_names.xlsx", sheet = "survey_5"))
survey5 <- survey5[!is.na(newname)]
  
  for(r_name in r_names){
    input_name <-  paste0(r_name, "_3.qs")
    output_name <- paste0(r_name, "_4.qs")
    input_data <-  file.path(dir_data_process, input_name)
    output_data <- file.path(dir_data_process, output_name)
     
    dt <- qs::qread(input_data)
    print(paste0("Opened: ", input_name)) 
    if (is.null(dt$q20)) dt$q20 <- dt$q20_new
    
    setnames(dt, survey5$oldname, survey5$newname, skip_absent = TRUE)
    
    # Save temp data ----------------------------------------------------------
    qs::qsave(dt, file = output_data)
    print(paste0('Saved:' , output_name))
  }



  