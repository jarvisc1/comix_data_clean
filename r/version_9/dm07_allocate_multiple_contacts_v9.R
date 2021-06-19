# Name: dm07_allocate_multiple_contacts.R
## Description: Assign each of the multiple contacts to a row
## Input file: combined_6_v9.qs
## Functions:
## Output file: combined_7_v9.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_6_v9.qs")
output_name <- paste0("combined_7_v9.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# No children's data for norway, just rename and save file.
# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

