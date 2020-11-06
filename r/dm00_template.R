## Name: 
## Description: 
## Input file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs
## Functions:
## Output file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs


# Packages ----------------------------------------------------------------
library(data.table)


# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')


# Countries ---------------------------------------------------------------
country_codes <- c("UK", "NL", "BE", "NO")



# Cleaning ----------------------------------------------------------------

for(country in country_codes){
  print(paste0("Start: ", country))
  
  # Setup input and output data and filepaths -------------------------------
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
  filenames <- filenames[!is.na(filenames$spss_name),]
  r_names <- filenames$r_name
  
  ## Change the number to be the relevant steps.
  for(r_name in r_names){
    input_name <-  paste0(r_name, "_50.qs")
    output_name <- paste0(r_name, "_55.qs")
    input_data <-  file.path(dir_data_process, input_name)
    output_data <- file.path(dir_data_process, output_name)
  
    dt <- qs::qread(input_data)
    print(paste0("Opened: ", input_name)) 
    
    ## User written function
    
    ## Save temp data
    qs::qsave(dt, file = output_data)
    print(paste0('Saved:' , output_name))
  }
}

  