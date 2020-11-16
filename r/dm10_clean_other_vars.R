## Name: dm09_clean_other_vars.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs



# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
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


# Participants ------------------------------------------------------------
part_cols <- grep("part", names(dt), value = TRUE)
print(paste0("Participant vars: ", length(part_cols)))

# Household members -------------------------------------------------------
hh_cols <- grep("hh", names(dt), value = TRUE)
print(paste0("Household vars: ", length(hh_cols)))


# Locations ---------------------------------------------------------------
loc_cols <- grep("area|region", names(dt), value = TRUE)
print(paste0("Location vars: ", length(loc_cols)))

# Map objects for labels --------------------------------------------------

## Create a rank of each survey within a country.

## This doesn't work

## This will only work on all of the data?
dt[, paneltemp := panel]
dt[country == "uk" & panel %in% c("A", "C"), paneltemp := "AC"]
dt[country == "uk" & panel %in% c("B", "D"), paneltemp := "BD"]
dt[, min_date := min(date, na.rm = T), by = .(country, paneltemp, wave)]
temp_rank <- dt[, .N, by = .(country, paneltemp, min_date) ]
temp_rank[, survey_round := rank(min_date), by = .(country) ]
temp_rank[, N := NULL]

dt <- merge(dt, temp_rank, all.x = TRUE, by = c("country","min_date", "paneltemp"))

dt[, min_date := min(date, na.rm = T), by = .(country, panel, wave)]

dt[country == "uk" & panel == "C", survey_round:= survey_round + 6]
dt[country == "uk" & panel == "D", survey_round:= survey_round + 7]
dt[, paneltemp := NULL]
dt[, rank1 := round(rank/2)]
dt[, table(survey_round, panel , country)]
dt[, table(min_date, panel , country)]


## Removing spaces ---------------------------------------------------------

dt[, part_social_group := gsub("  ", " ", part_social_group)]

# Clean dates -------------------------------------------------------------
## Clean and defines dates

# Extract date columns
date_cols <- str_subset(names(dt), "date")
print(paste0("Date vars: ", length(date_cols)))

# SPSS dates --------------------------------------------------------------
## SPSS dates start at "1582-10-14 and are recorded in seconds

spss_date_cols <- c(
  "hhm_seek_gov_info_date",
  "hhm_phone_gp_date",
  "hhm_visit_gp_date",
  "hhm_visit_urgent_date",
  "hhm_visit_ae_date",
  "hhm_visit_testing_date",
  "hhm_cont_adm_hosp_date",
  "hhm_quarantine_start_date",
  "hhm_quarantine_end_date",
  "hhm_isolation_start_date",
  "hhm_isolation_end_date",
  "hhm_work_closure_start_date",
  "hhm_work_closure_end_date")

spss_date <- function(x) as.Date(as.numeric(x)/86400, origin = "1582-10-14")
dt[, (spss_date_cols) := lapply(.SD, spss_date), .SDcols = spss_date_cols ]

# Work dates --------------------------------------------------------------
## The date for the UK for Panel A wave 1 and 2, Panel B wave 1 are in a different
## format from all other countries. 
## First 3 weeks were dd/mm/yyyy = "%d/%m/%Y"
## Since then it's been Wednesday, dd, Months = "%A, %d %B"

work_date_cols <- str_subset(names(dt), "work_date")

## Change early date formats
dt[(country == "uk" & panel %in% c("A") & wave <= 2) |
     (country == "uk" & panel %in% c("B") & wave == 1), 
   (work_date_cols) :=
     lapply(.SD, as.Date, format = "%d/%m/%Y"),
   .SDcols = work_date_cols]

## Convert later date formats
dt[!((country == "uk" & panel %in% c("A") & wave <= 2) |
       (country == "uk" & panel %in% c("B") & wave == 1)), 
   (work_date_cols) :=
     lapply(.SD, as.Date, format = "%A, %d %B"),
   .SDcols = work_date_cols]

## Turn to numeric
dt[, 
   (work_date_cols) :=
     lapply(.SD, as.numeric),
   .SDcols = work_date_cols]

## Change to dates
dt[, 
   (work_date_cols) :=
     lapply(.SD, as.Date, origin = "1970-01-01"),
   .SDcols = work_date_cols]

