## Name: dm02_add_cnty_panel_wave.R
## Description: Check if country, panel, and wave are present, if not add.
## Input file: cnty_wkN_yyyymmdd_pN_wvN_1.qs
## Functions: country_checker, wave_checker, panel_checker
## Output file: cnty_wkN_yyyymmdd_pN_wvN_2.qs

# Packages ----------------------------------------------------------------
library(data.table)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')
source('r/functions/check_cnty_panel_wave.R')

# Countries ---------------------------------------------------------------
country_codes <- c("UK", "NL", "BE", "NO")

# Cleaning ----------------------------------------------------------------

for(country in country_codes){
   print(paste0("Start: ", country))

   # Setup input and output data and filepaths -------------------------------
   filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
   filenames <- filenames[!is.na(filenames$spss_name),]
   r_names <- filenames$r_name
   
   ## This script loads _1.qs files and save them as _2.qs files
   for(r_name in r_names){
      input_name <-  paste0(r_name, "_1.qs")
      output_name <- paste0(r_name, "_2.qs")
      input_data <-  file.path(dir_data_process, input_name)
      output_data <- file.path(dir_data_process, output_name)
      
      ## Read in _1 data
      dt <- qs::qread(input_data)
      print(paste0("Opened: ", input_name)) 
      ## Add wave, panel, and country variables ----------------------------------
   
      ## get country, panel, and wave from filename
      panel <- str_extract(r_name, "_p[A-Z]_")
      panel <- substring(panel, first = 3, last = 3)
      wave <- str_extract(r_name, "_wv[0-9]{2}")
      wave <- str_extract(wave, "[0-9]{2}")
      wave <- as.numeric(str_extract(wave, "[0-9]{1,2}"))
      country <- str_extract(r_name, ".+?(?=_)")
      
      # Country -----------------------------------------------------------------
      dt <- country_checker(dt, country)
      
      # Panel -------------------------------------------------------------------
      dt <- panel_checker(  dt, panel)
      
      # Wave --------------------------------------------------------------------
      dt <- wave_checker(   dt, wave)
   
      ## Save _2 file
      qs::qsave(dt, file = output_data)
      print(paste0('Saved: ' , output_name))
   }
}
