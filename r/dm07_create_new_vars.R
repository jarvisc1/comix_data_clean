## Name: dm_create_new_vars.R
## Description: Add new variables to the dataset.
## Input file: combined_7.qs
## Functions:
## Output file: combine_8.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate)
library(stringr)


# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_7.qs")
output_name <- paste0("combined_8.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Map objects for labels --------------------------------------------------

map_minutes_min <- c(
  "<5m"     = 0,
  "5m-14m"  = 5,
  "15m-59m" = 15,
  "60m-4h"  = 60,
  "4h+"     = 240
)
map_minutes_max <- c(
  "<5m"     = 5,
  "5m-14m"  = 15,
  "15m-59m" = 60,
  "60m-4h"  = 240,
  "4h+"     = 1440
)



# Add dates ---------------------------------------------------------------
## Survey date is given as separate day, month, and year
dt[, survey_date := as.Date(paste0(year,"-", month,"-", day ))]

dt[, date := survey_date - 1]
dt[, weekday := weekdays(date)]
dt[, survey_weekday := weekdays(survey_date)]
dt[, week := week(date)]
## Need to add a survey week. We're currently putting week from start of survey
#dt[, survey_week := week(date)]

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

