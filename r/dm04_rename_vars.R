## Name: dm04_rename_vars.R
## Description: Rename the variables using a csv file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_3.qs
## Functions: change_names changenamesv2
## Output file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## NOTE: !Need to sort out so only one change names function

# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')
source('r/functions/change_names.R')

# Countries ---------------------------------------------------------------
country_codes <- c("UK", "NL", "BE", "NO")

# Pick a country ----------------------------------------------------------

country_codes <- c("UK", "NL", "BE", "NO")

for(country in country_codes){
  print(paste0("Start: ", country))
  
  # Setup input and output data and filepaths -------------------------------
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
  filenames <- filenames[!is.na(filenames$spss_name),]
  r_names <- filenames$r_name
  
  for(r_name in r_names){
    input_name <-  paste0(r_name, "_3.qs")
    output_name <- paste0(r_name, "_4.qs")
    input_data <-  file.path(dir_data_process, input_name)
    output_data <- file.path(dir_data_process, output_name)
  
    dt <- qs::qread(input_data)
    print(paste0("Opened: ", input_name)) 
    
    # Read in variable names    
    varnames <- as.data.table(read.csv("codebook/var_names.csv"))
    
    # Different names for panel E and F in UK
    if ((as.character(dt$panel[1]) %in% c("E", "F"))) {
      varnames <- as.data.table(read.csv("codebook/var_names_v2.csv"))
    }
    ## Sometime strange unicode in file reading due to mac/windows
    names(varnames) <- c("var", "ipsos_varname", "type", "tablename", "new_name", "changed")
    
    ## Rename any vars that aren't present or change names
    if (is.null(dt$q20)) dt$q20 <- dt$q20_new
    ## User written function
    
    if ((as.character(dt$panel[1]) %in% c("E", "F"))) {
      dt <- change_namesv2(dt, varnames, tolower(dt$qcountry))
    } else{
      dt <- change_names(dt, varnames, tolower(dt$qcountry))
    }
    
    
    ## Save temp data
    qs::qsave(dt, file = output_data)
    print(paste0('Saved:' , output_name))
  }
}

  