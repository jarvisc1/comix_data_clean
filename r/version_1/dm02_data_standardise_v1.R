## Name: dm02_data_standardise_v1.R
## Description: Check if country, panel, and wave are present, if not add.
##              Make the participant id unique across panels but within countries
##              Rename child data questions
##              Standardise loop and scale question names
## Input file: cnty_wkN_yyyymmdd_pN_wvN_1.qs
## Functions: country_checker, wave_checker, panel_checker, standardise_names
## Output file: cnty_wkN_yyyymmdd_pN_wvN_2.qs

# Packages ----------------------------------------------------------------
library(data.table)
library(stringr)

# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')
source('./r/version_1/functions/check_cnty_panel_wave_v1.R')
source('./r/version_1/functions/standardise_names_v1.R')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country_codes <- c("UK", "NL", "BE", "NO")

# Cleaning ----------------------------------------------------------------

for(country in country_codes){
   print(paste0("Start: ", country))

   # Setup input and output data and filepaths -------------------------------
   filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
   filenames <- filenames[!is.na(filenames$spss_name) & 
                             filenames$survey_version == 1,]
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
      week <- str_extract(r_name, "_wk[0-9]{2}")
      week <- str_extract(week, "[0-9]{2}")
      country <- str_extract(r_name, ".+?(?=_)")
      
      dt[, survey_round := week]
      
      # Country -----------------------------------------------------------------
      dt <- country_checker(dt, country)
      
      # Panel -------------------------------------------------------------------
      dt <- panel_checker(  dt, panel)
      
      # Wave --------------------------------------------------------------------
      dt <- wave_checker(   dt, wave)
      

      # Participant ID -------------------------------------------------------------------------
      # The same participants ID are used for each panel and country.
      ## We do not anticipate a panel having more than 10,000 people.
      ## Start at 10,000 and add 10,000 for each panel. 
      ## B starts from 20,000
      ## C starts from 30,000
      dt[respondent_id < 10000, respondent_id := respondent_id + 10000*as.numeric(factor(panel, LETTERS))]

      # Standardise names -------------------------------------------------------
      names(dt) <- standardise_names(names(dt))
      
      # Misspelt name -----------------------------------------------------------
      names(dt) <- gsub("hhcompconfrim","hhcompconfirm", names(dt))
   
      ## Save _2 file
      qs::qsave(dt, file = output_data)
      print(paste0('Saved: ' , output_name))
   }
}
