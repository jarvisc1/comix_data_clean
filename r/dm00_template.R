## dm_data_clean
library(data.table)

## Input file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs
## Functions:
## Output file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs

## Source relevant files
source('r/setup_filepaths.r')

# Pick a country ----------------------------------------------------------

country_codes <- c("UK", "NL", "BE", "NO")

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
    ##---------------
    qs::qsave(dt, file = output_data)
    print(paste0('Saved:' , output_name))
  }
}

  