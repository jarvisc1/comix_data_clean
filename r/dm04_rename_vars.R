## Name: dm04_rename_vars.R
## Description: Rename the variables using a csv file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_3.qs
## Functions: 
## Output file: cnty_wkN_yyyymmdd_pN_wvN_4.qs

# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
# country_codes <- c("UK", "NL", "BE", "NO")
country_codes <- readxl::excel_sheets('data/spss_files.xlsx')
country_codes <- grep("summary", country_codes, ignore.case = TRUE, invert = TRUE, value = TRUE)


for(country in country_codes){
  print(paste0("Start: ", country))
  
  # Setup input and output data and filepaths -------------------------------
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
  filenames <- filenames[!is.na(filenames$spss_name),]
  r_names <- filenames$r_name
  
  survey1 <- as.data.table(readxl::read_excel("codebook/var_names.xlsx", sheet = "survey_1"))
  survey2 <- as.data.table(readxl::read_excel("codebook/var_names.xlsx", sheet = "survey_2"))
  survey1 <- survey1[!is.na(newname)]
  survey2 <- survey2[!is.na(newname)]
  
  for(r_name in r_names){
    input_name <-  paste0(r_name, "_3.qs")
    output_name <- paste0(r_name, "_4.qs")
    input_data <-  file.path(dir_data_process, input_name)
    output_data <- file.path(dir_data_process, output_name)
  
    dt <- qs::qread(input_data)
    print(paste0("Opened: ", input_name)) 
    
    # Different names for panel E and F in UK
    if ((as.character(dt$panel[1]) %in% c("E", "F"))) {
      setnames(dt, survey2$oldname, survey2$newname, skip_absent = TRUE)
    } else {
      setnames(dt, survey1$oldname, survey1$newname, skip_absent = TRUE)
      
    }
    
    if (is.null(dt$q20)) dt$q20 <- dt$q20_new 
    ## User written function
    
    
    
    ## Save temp data
    qs::qsave(dt, file = output_data)
    print(paste0('Saved:' , output_name))
  }
}

  