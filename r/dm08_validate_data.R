## Name: dm_create_new_vars.R
## Description: Add new variables to the dataset.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(validate)


# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_7.qs")
output_name <- paste0("combined_8.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Validation rules --------------------------------------------------




# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))