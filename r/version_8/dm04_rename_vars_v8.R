## Name: dm04_rename_vars_v8.R
## Description: Rename the variables using a csv file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_3.qs
## Functions: 
## Output file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## NOTE: !Need to sort out so only one change names function

# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
  latest <-  1 ## Change to zero if you to test all interactively
} else if(args[1] == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Updating ", ifelse(latest==0, "All", "Latest")))

# Countries ---------------------------------------------------------------
country <- "UK"

print(paste0("Start: ", country))

# Setup input and output data and filepaths -------------------------------
filenames <- readxl::read_excel('data/spss_uk.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name) & 
                         filenames$survey_version == 8,]

if(latest == 1){
  filenames <- tail(filenames, 1)
}

r_names <- filenames$r_name

# Load dataname spreadsheet -----------------------------------------------
survey <- as.data.table(read.csv("codebook/var_names_v3.csv", col.names = c("oldname", "newname")))
survey <- survey[!is.na(newname)]
  
for(r_name in r_names){
  input_name <-  paste0(r_name, "_3.qs")
  output_name <- paste0(r_name, "_4.qs")
  input_data <-  file.path(dir_data_process, input_name)
  output_data <- file.path(dir_data_process, output_name)

  dt <- qs::qread(input_data)
  print(paste0("Opened: ", input_name)) 
  setnames(dt, survey$oldname, survey$newname, skip_absent = TRUE)
    
  
  if (is.null(dt$q20)){
    if(!is.null(dt$q20_new))  dt$q20 <- dt$q20_new 
    if(!is.null(dt$q20_original))  dt$q20 <- dt$q20_original
  }
  
  # Save temp data ----------------------------------------------------------
  qs::qsave(dt, file = output_data)
  print(paste0('Saved:' , output_name))
}




  