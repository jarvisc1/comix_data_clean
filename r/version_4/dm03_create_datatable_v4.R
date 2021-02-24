## Name: dm03_reshape_wide_to_long_v4.R
## Description: Reshape the survey data from wide to long and deal with the 
##              various type of scale and loop variables that are in the survey
## Input file:  cnty_wkN_yyyymmdd_pN_wvN_2.qs
## Functions:   survey_to_datatable
## Output file: cnty_wkN_yyyymmdd_pN_wvN_3.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')
source('./r/version_4/functions/survey_to_datatable_v4.R')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("group")) group <- "G1"
if(length(args) == 1) group <- args

# Setup input and output data and filepaths -------------------------------
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = group)
filenames <- filenames[!is.na(filenames$spss_name) & 
                         filenames$survey_version == 4,]
r_names <- filenames$r_name

for(r_name in r_names){
  input_name <-  paste0(r_name, "_2.qs")
  output_name <- paste0(r_name, "_3.qs")
  input_data <-  file.path(dir_data_process, input_name)
  output_data <- file.path(dir_data_process, output_name)

  dt <- qs::qread(input_data)
  print(paste0("Opened: ", input_name)) 
  
  cols_start <- ncol(dt)
  # Remove empty columns -------------------------------------------------
  emptycols_na <- colSums(is.na(dt)) == nrow(dt)
  if(sum(emptycols_na) > 0 ){
  emptycols_na <- names(emptycols_na[emptycols_na])
  set(dt, j = emptycols_na, value = NULL)
  }  
  ## User written function
  dt <- survey_to_datatable(dt)
  # Remove empty rows again -------------------------------------------------
  emptycols_na <- colSums(is.na(dt)) == nrow(dt)
  if(sum(emptycols_na) > 0 ){
    emptycols_na <- names(emptycols_na[emptycols_na])
    set(dt, j = emptycols_na, value = NULL)
  }  
  
  vars <- c("respondent_id", "panel", "wave", "country", "table_row")
  cnt <- grep("contact", names(dt), value = TRUE)
  vars <- c(vars, cnt)
  rows_start <- nrow(dt)
  missing <- rowSums(!is.na(dt[,.SD, .SDcols = !vars]))==0
  dt <- dt[!missing]
  
  print(paste0("Reduced from ", cols_start, " to ", ncol(dt), " columns"))
  print(paste0("Removed ", rows_start-nrow(dt), " empty rows"))
  
  ## Save _3 data
  qs::qsave(dt, file = output_data)
  print(paste0('Saved:' , output_name))
}


  
