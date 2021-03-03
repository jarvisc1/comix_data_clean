## Name: dm05_combine_data_v6.R
## Description: Combine all of the temporary cleaning data into one qs file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## Functions:
## Output file: combined_5_v3.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Countries ---------------------------------------------------------------
country <- "NL"


# Cleaning ----------------------------------------------------------------
dt_list <- list()

print(paste0("Start: ", country))

# Setup input and output data and filepaths -------------------------------
filenames <- readxl::read_excel('data/spss_files_nl.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name) & 
                         filenames$survey_version == 6,]
r_names <- filenames$r_name

for(r_name in r_names){
  input_name <-  paste0(r_name, "_4.qs")
  output_name <- paste0("combined_5_v6.qs")
  input_data <-  file.path(dir_data_process, input_name)
  output_data <- file.path(dir_data_process, output_name)

  dt <- qs::qread(input_data)
  #print(paste0("Opened: ", input_name)) 
  
  dt_list[[r_name]] <- dt
}


dt_combined <- rbindlist(dt_list, use.names = TRUE, fill = TRUE)

## Save combined file
qs::qsave(dt_combined, file = output_data)
print(paste0('Saved:' , output_name))
  
