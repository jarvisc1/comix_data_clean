## Name: dm09_clean_household_v1.R
## Description: Clean variables related to household members.
## Input file: combined_9_v1.qs
## Functions:
## Output file: combined_10_v1.qs, households_v1



# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_9_v1.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_10_v1.qs")
output_hhms <- paste0("households_v1.qs")

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
dt[between(hh_size_int,6,13), hh_size_group := "5+",]

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


# Symptoms ----------------------------------------------------------------

dt[, hhm_symp_ache := YesNoNA_Ind(hhm_symp_ache)]
dt[, hhm_symp_congestion := YesNoNA_Ind(hhm_symp_congestion)]
dt[, hhm_symp_cough := YesNoNA_Ind(hhm_symp_cough)]
dt[, hhm_symp_dk := YesNoNA_Ind(hhm_symp_dk)]
dt[, hhm_symp_fever := YesNoNA_Ind(hhm_symp_fever)]
dt[, hhm_symp_no_answer := YesNoNA_Ind(hhm_symp_no_answer)]
dt[, hhm_symp_none := YesNoNA_Ind(hhm_symp_none)]
dt[, hhm_symp_sob := YesNoNA_Ind(hhm_symp_sob)]
dt[, hhm_cont_adm_hosp := YesNoNA_Ind(hhm_cont_adm_hosp)]
dt[, hhm_symp_sore_throat := YesNoNA_Ind(hhm_symp_sore_throat)]
dt[, hhm_symp_tired := YesNoNA_Ind(hhm_symp_tired)]

# Avoid work -------------------------------------------------------------

dt[, hhm_avoid_work_reason_covidcarer_outside := map_yn_res[hhm_avoid_work_reason_covidcarer_outside]]
dt[, hhm_avoid_work_reason_hh_isolation := map_yn_res[hhm_avoid_work_reason_hh_isolation]]
dt[, hhm_avoid_work_reason_hh_quarantine := map_yn_res[hhm_avoid_work_reason_hh_quarantine]]
dt[, hhm_avoid_work_reason_other := map_yn_res[hhm_avoid_work_reason_other]]
dt[, hhm_avoid_work_reason_other_illness := map_yn_res[hhm_avoid_work_reason_other_illness]]
dt[, hhm_avoid_work_reason_othercarer_outside := map_yn_res[hhm_avoid_work_reason_othercarer_outside]]
dt[, hhm_avoid_work_reason_school_closure := map_yn_res[hhm_avoid_work_reason_school_closure]]
dt[, hhm_avoid_work_reason_self_isolation := map_yn_res[hhm_avoid_work_reason_self_isolation]]
dt[, hhm_avoid_work_reason_self_quarantine := map_yn_res[hhm_avoid_work_reason_self_quarantine]]
dt[, hhm_avoid_work_school_14day_quar := map_yn_res[hhm_avoid_work_school_14day_quar]]
dt[, hhm_avoid_work_school_7day_iso := map_yn_res[hhm_avoid_work_school_7day_iso]]
dt[, hhm_avoid_work_school_caring_coivd_not_confirmed := map_yn_res[hhm_avoid_work_school_caring_coivd_not_confirmed]]
dt[, hhm_avoid_work_school_caring_covid_confirmed := map_yn_res[hhm_avoid_work_school_caring_covid_confirmed]]
dt[, hhm_avoid_work_school_child_home := map_yn_res[hhm_avoid_work_school_child_home]]
dt[, hhm_avoid_work_school_illnes := map_yn_res[hhm_avoid_work_school_illnes]]
dt[, hhm_avoid_work_school_other := map_yn_res[hhm_avoid_work_school_other]]

# Who will look after children when school closed -------------------------------------------------------------
dt[, hhm_close_childcare_grandparent := map_yn_res[hhm_close_childcare_grandparent]]
dt[, hhm_close_childcare_neighbour_friend := map_yn_res[hhm_close_childcare_neighbour_friend]]
dt[, hhm_close_childcare_not_required := map_yn_res[hhm_close_childcare_not_required]]
dt[, hhm_close_childcare_other := map_yn_res[hhm_close_childcare_other]]
dt[, hhm_close_childcare_parent_annual_leave := map_yn_res[hhm_close_childcare_parent_annual_leave]]
dt[, hhm_close_childcare_parent_carer_leave := map_yn_res[hhm_close_childcare_parent_carer_leave]]
dt[, hhm_close_childcare_parent_part_time_work := map_yn_res[hhm_close_childcare_parent_part_time_work]]
dt[, hhm_close_childcare_parent_unemployed := map_yn_res[hhm_close_childcare_parent_unemployed]]
dt[, hhm_close_childcare_parent_unpaid_leave := map_yn_res[hhm_close_childcare_parent_unpaid_leave]]
dt[, hhm_close_childcare_parent_wfh := map_yn_res[hhm_close_childcare_parent_wfh]]
dt[, hhm_close_childcare_school := map_yn_res[hhm_close_childcare_school]]
dt[, hhm_close_childcare_sibling := map_yn_res[hhm_close_childcare_sibling]]
dt[, hhm_close_childcare_sitter_paid := map_yn_res[hhm_close_childcare_sitter_paid]]
dt[, hhm_close_childcare_sitter_unpaid := map_yn_res[hhm_close_childcare_sitter_unpaid]]

# Negative impact of school closure -------------------------------------------------------------
dt[, hhm_neg_annual_leave := map_yn_res[hhm_neg_annual_leave]]
dt[, hhm_neg_dont_know := map_yn_res[hhm_neg_dont_know]]
dt[, hhm_neg_no_carer_leave := map_yn_res[hhm_neg_no_carer_leave]]
dt[, hhm_neg_no_paid_by_employer := map_yn_res[hhm_neg_no_paid_by_employer]]
dt[, hhm_neg_no_paid_by_government := map_yn_res[hhm_neg_no_paid_by_government]]
dt[, hhm_neg_no_wfh := map_yn_res[hhm_neg_no_wfh]]
dt[, hhm_neg_prefer_not_answer := map_yn_res[hhm_neg_prefer_not_answer]]
dt[, hhm_neg_yes_lost_all_income := map_yn_res[hhm_neg_yes_lost_all_income]]
dt[, hhm_neg_yes_other := map_yn_res[hhm_neg_yes_other]]
dt[, hhm_neg_yes_partial_pay_employer := map_yn_res[hhm_neg_yes_partial_pay_employer]]
dt[, hhm_neg_yes_partial_pay_government := map_yn_res[hhm_neg_yes_partial_pay_government]]

## How did the children get looked after?
dt[, hhm_not_attend_childcare_grandparent := map_yn_res[hhm_not_attend_childcare_grandparent]]
dt[, hhm_not_attend_childcare_neighbour_friend := map_yn_res[hhm_not_attend_childcare_neighbour_friend]]
dt[, hhm_not_attend_childcare_not_required := map_yn_res[hhm_not_attend_childcare_not_required]]
dt[, hhm_not_attend_childcare_other := map_yn_res[hhm_not_attend_childcare_other]]
dt[, hhm_not_attend_childcare_parent_annual_leave := map_yn_res[hhm_not_attend_childcare_parent_annual_leave]]
dt[, hhm_not_attend_childcare_parent_carer_leave := map_yn_res[hhm_not_attend_childcare_parent_carer_leave]]
dt[, hhm_not_attend_childcare_parent_part_time_work := map_yn_res[hhm_not_attend_childcare_parent_part_time_work]]
dt[, hhm_not_attend_childcare_parent_unemployed := map_yn_res[hhm_not_attend_childcare_parent_unemployed]]
dt[, hhm_not_attend_childcare_parent_unpaid_leave := map_yn_res[hhm_not_attend_childcare_parent_unpaid_leave]]
dt[, hhm_not_attend_childcare_parent_wfh := map_yn_res[hhm_not_attend_childcare_parent_wfh]]
dt[, hhm_not_attend_childcare_school_care := map_yn_res[hhm_not_attend_childcare_school_care]]
dt[, hhm_not_attend_childcare_sibling := map_yn_res[hhm_not_attend_childcare_sibling]]
dt[, hhm_not_attend_childcare_sitter_paid := map_yn_res[hhm_not_attend_childcare_sitter_paid]]
dt[, hhm_not_attend_childcare_sitter_unpaid := map_yn_res[hhm_not_attend_childcare_sitter_unpaid]]

# HHM visiting or seeking health help -------------------------------------
dt[, hhm_visit_ae := map_yn_res[hhm_visit_ae]]
dt[, hhm_visit_gp := map_yn_res[hhm_visit_gp]]
dt[, hhm_visit_urgent := map_yn_res[hhm_visit_urgent]]
dt[, hhm_visit_testing := map_yn_res[hhm_visit_testing]]
dt[, hhm_phone_gp := map_yn_res[hhm_phone_gp]]
dt[, hhm_seek_gov_info := map_yn_res[hhm_seek_gov_info]]
dt[, hhm_reaction_dk := map_yn_res[hhm_reaction_dk]]
dt[, hhm_reaction_none := map_yn_res[hhm_reaction_none]]
dt[, hhm_cont_adm_hosp_other := map_yn_res[hhm_cont_adm_hosp_other]]
dt[, hhm_reaction_no_answer := map_yn_res[hhm_reaction_no_answer]]

# Map questions -----------------------------------------------------------

#dt[, hhm_covid_test_recent := map_test_recent[hhm_covid_test_recent]]
dt[, hhm_covid_test_result := map_test_result[hhm_covid_test_result]]

##  yes no  prefer not to say and restrictions

dt[, hhm_covid_contact := map_yn_res[hhm_covid_contact]]
dt[, hhm_covid_test := map_yn_res[hhm_covid_test]]
dt[, hhm_high_risk := map_yn_res[hhm_high_risk]]
dt[, hhm_isolate := map_yn_res[hhm_isolate]]
dt[, hhm_isolate_atleast_one_day := map_yn_res[hhm_isolate_atleast_one_day]]
dt[, hhm_educaton_closed := map_yn_res[hhm_educaton_closed]]
dt[, hhm_work_closed := map_yn_res[hhm_work_closed]]
dt[, hhm_avoid_work_school_other_reason1 := map_yn_res[hhm_avoid_work_school_other_reason1]]
dt[, hhm_avoid_work_school_other_reason2 := map_yn_res[hhm_avoid_work_school_other_reason2]]
dt[, hhm_isolation_end_other := map_yn_res[hhm_isolation_end_other]]
dt[, hhm_isolation_start_other := map_yn_res[hhm_isolation_start_other]]
dt[, hhm_limit_school := map_yn_res[hhm_limit_school]]
dt[, hhm_limit_school_atleast_day := map_yn_res[hhm_limit_school_atleast_day]]
dt[, hhm_limit_work := map_yn_res[hhm_limit_work]]
dt[, hhm_limit_work_atleast_day := map_yn_res[hhm_limit_work_atleast_day]]
dt[, hhm_phone_gp_other := map_yn_res[hhm_phone_gp_other]]
dt[, hhm_pregnant := map_yn_res[hhm_pregnant]]
dt[, hhm_quarantine := map_yn_res[hhm_quarantine]]
dt[, hhm_quarantine_end_other := map_yn_res[hhm_quarantine_end_other]]
dt[, hhm_quarantine_one_day := map_yn_res[hhm_quarantine_one_day]]
dt[, hhm_quarantine_start_other := map_yn_res[hhm_quarantine_start_other]]
dt[, hhm_seek_gov_info_other := map_yn_res[hhm_seek_gov_info_other]]
dt[, hhm_visit_ae_other := map_yn_res[hhm_visit_ae_other]]
dt[, hhm_visit_gp_other := map_yn_res[hhm_visit_gp_other]]
dt[, hhm_visit_testing_other := map_yn_res[hhm_visit_testing_other]]
dt[, hhm_visit_other := map_yn_res[hhm_visit_other]]
dt[, hhm_work_closure_end_other := map_yn_res[hhm_work_closure_end_other]]
dt[, hhm_work_closure_start_other := map_yn_res[hhm_work_closure_start_other]]
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
