## Name: dm06_clean_ages_cnts.R
## Description: Run checks and process variables already present in the data.
## Input file: combined_5.qs
## Functions:
## Output file: combined_6.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5.qs")
output_name <- paste0("combined_6.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Remove variables --------------------------------------------------------

dt[, cultureinfo := NULL]
dt[, data_acum := NULL]
dt[, part_employ_type := NULL]
dt[, main_intro_screen := NULL]
dt[, privacypolicy_insert := NULL]
dt[, quotagerange := NULL]
dt[, sniffer_device_type_final := NULL]
dt[, sniffer_device_type_initial := NULL]
dt[, survey_boost := NULL]
dt[, survey_main := NULL]
dt[, uksg_version := NULL]
## not need as combined in hh_type
dt[, hh_type_partner := NULL]
dt[, hh_type_non_relative := NULL]
dt[, hh_type_alone := NULL]
dt[, hh_type_child_under_18 := NULL]
dt[, hh_type_child_18_plus := NULL]
dt[, hh_type_grandchild_under_18 := NULL]
dt[, hh_type_grandchild_18_plus := NULL]
dt[, hh_type_older_relatives := NULL]
dt[, hh_type_siblings_under_18 := NULL]
dt[, hh_type_siblings_18_plus := NULL]
dt[, hh_type_other_relative := NULL]

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))








    
  