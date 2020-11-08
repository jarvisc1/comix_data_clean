## Name: dm_validate_data.R
## Description: Perform data checks.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(validate)
library(errorlocate)


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

## Two approaches check_that for short checks

checks <- check_that(dt, 
          age_pos =  part_age > 0,
          len_id = panel %in% LETTERS[1:6],
          fd = date <= Sys.Date())
summary(checks)

## Validator for running a lot of rules
# Then the rules and confronting are done in different steps. 
v <- validator(
          age_pos =  part_age > 0,
          len_id = panel %in% LETTERS[1:6],
          fd = date <= Sys.Date()
          )

cf <- confront(dt, v)
summary(cf)

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))