## Name: dm09_clean_household_v3.R
## Description: Clean variables related to household members.
## Input file: combined_9_v3.qs
## Functions:
## Output file: combined_10_v3.qs, households_v3



# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_9_v3.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_10_v3.qs")
output_hhms <- paste0("households_v3.qs")

## Save household data.
current_date <- Sys.Date()
output_hhms_date <- paste(current_date, output_hhms, sep = "_")
output_data <- file.path(dir_data_process, output_name)
output_data_hhms <- file.path("data/clean", output_hhms)
output_data_hhms_date <- file.path("data/clean/archive", output_hhms_date)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Map objects for labels --------------------------------------------------


map_test_recent <- c(
  "Don’t know" = "unknown", 
  "Prefer not to answer" = "no answer",
  "Not tested" = "not tested", 
  "Tested and the test showed {#i_they.response.label} have Coronavirus currently" = "positive", 
  "Tested, and the test showed {#i_they.response.label} do not have Coronavirus currently" = "negative", 
  "Yes, and {#im_are.response.label} still waiting to hear the result" = "waiting for result"
)

map_test_result <- c(
  "Don’t know" = "unknown", 
  "Prefer not to answer" = "no answer",
  "Not tested" = "not tested", 
  "Tested and the test showed I/they have Coronavirus" = "positive", 
  "Tested, and the test showed I/they <u>do not</u> have Coronavirus" = "negative" , 
  "Tested, and the test showed I/they do not have Coronavirus" = "negative", 
  "Yes, and I’m still waiting to hear the result" = "waiting for result")

map_yn_res <- c(
  "Yes" = "yes",
  "No" = "no", 
  "Don’t know" = "unknown", 
  "Not applicable" = "not applicable", 
  "Prefer not to answer" = "no answer",
  "{#Q45_help_insert} still isolating" = "still isolating",
  "{#Q43_help_insert} still in quarantine" = "still in quarantine",
  "It is still closed" = "still closed",
  "Yes, currently infected" = "infected", 
  "Yes, passed away" = "passed away",
  "Yes, recovered" = "recovered"
)



YesNoNA_Ind = function(x)
{
  ifelse(x == "Yes", 1,
         ifelse(x == "No", 0, NA))
}




# Household size ----------------------------------------------------------

## We are changing string to numeric and it drops NA's switch these warnings off
oldw <- getOption("warn")
options(warn = -1)

dt[, hh_size_int := as.numeric(hh_size) + 1]
dt[, hh_size_int := as.numeric(hh_size)]
dt[hh_size == "none", hh_size_int := 1]
dt[hh_size == "11 or more", hh_size_int := 12]
dt[hh_size_int == 1, hh_size_group := "1",]
dt[hh_size_int == 2, hh_size_group := "2",]
dt[between(hh_size_int,3,5), hh_size_group := "3-5",]
dt[between(hh_size_int,5,13), hh_size_group := "5+",]

dt[, hh_size := hh_size_int]
dt[, hh_size_int := NULL]

## Switch warnings back on
options(warn = oldw)

# Fill in for all observations --------------------------------------------
dt[, hh_size := first(hh_size), by = .(part_wave_uid)]
dt[, hh_size_group := first(hh_size_group), by = .(part_wave_uid)]

# Clean dates -------------------------------------------------------------
## Clean and defines dates

# Extract date columns
date_cols <- str_subset(names(dt), "date")
print(paste0("Date vars: ", length(date_cols)))

# SPSS dates --------------------------------------------------------------
## SPSS dates start at "1582-10-14 and are recorded in seconds

## Will be relevant for vaccination but not for much else
# spss_date_cols <- c(
#   
#   "hhm_work_closure_start_date",
#   "hhm_work_closure_end_date")
# 
# spss_date <- function(x) as.Date(as.numeric(x)/86400, origin = "1582-10-14")
# dt[, (spss_date_cols) := lapply(.SD, spss_date), .SDcols = spss_date_cols ]


# Symptoms ----------------------------------------------------------------

dt[, hhm_symp_congestion := YesNoNA_Ind(hhm_symp_congestion)]
dt[, hhm_symp_cough := YesNoNA_Ind(hhm_symp_cough)]
dt[, hhm_symp_dk := YesNoNA_Ind(hhm_symp_dk)]
dt[, hhm_symp_fever := YesNoNA_Ind(hhm_symp_fever)]
dt[, hhm_symp_no_answer := YesNoNA_Ind(hhm_symp_no_answer)]
dt[, hhm_symp_none := YesNoNA_Ind(hhm_symp_none)]
dt[, hhm_symp_sob := YesNoNA_Ind(hhm_symp_sob)]
dt[, hhm_symp_sore_throat := YesNoNA_Ind(hhm_symp_sore_throat)]



# Map questions -----------------------------------------------------------

##  yes no  prefer not to say and restrictions

dt[, hhm_employstatus := tolower(hhm_employstatus)]
dt[, hhm_student := tolower(hhm_student)]
dt[, hhm_student_college := tolower(hhm_student_college)]
dt[, hhm_student_nursery := tolower(hhm_student_nursery)]
dt[, hhm_student_school := tolower(hhm_student_school)]
dt[, hhm_contact := tolower(hhm_contact)]
dt[, hhm_student_university := tolower(hhm_student_university)]



# Other reasons -----------------------------------------------------------
# 
# dt[, table(hhm_close_childcare_other_reason)]
# dt[, table(hhm_neg_yes_other_reason)]


# Filter to household data -------------------------------------------------------

hhm_names <- grep("hhm|hh", names(dt), value = TRUE)


#hhm_names

#names(dt)[!names(dt) %in% hhm_names]
id_vars <- c("country",
             "panel",
             "wave",
             "date",
             "survey_date",
             "weekday",
             "part_id",
             "part_uid",
             "part_wave_uid",
             "contact_flag",
             "part_flag",
             "contact")
hhm_vars <- c(id_vars, hhm_names)
#names(dt)[!names(dt) %in% hhm_vars]

hhms <- dt[hhm_flag == TRUE, ..hhm_vars]
# Do not remove household variables.-------------------------------------------------------------------------

## They will be used in the next script and change to part variables

# Only keep household and participants ------------------------------------

dt <- dt[ part_flag == TRUE]

cols_start <- ncol(dt)
## Remove completely empty columns 
emptycols_na <- colSums(is.na(dt)) == nrow(dt)
if(sum(emptycols_na) > 0 ){
  emptycols_na <- names(emptycols_na[emptycols_na])
  set(dt, j = emptycols_na, value = NULL)
}  

print(paste0("Reduced from ", cols_start, " to ", ncol(dt), " columns"))

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Removed household only data'))
print(paste0('Saved: ' , output_name))
# Save household data ---------------------------------------------------------------
qs::qsave(hhms, file = output_data_hhms)
qs::qsave(hhms, file = output_data_hhms_date)
print(paste0('Saved: ' , output_hhms))
print(paste0('Saved: ' , output_hhms_date))