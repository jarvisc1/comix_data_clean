## Name: dm09_clean_household.R
## Description: Clean variables related to household members.
## Input file: combined_9.qs
## Functions:
## Output file: combined_10.qs



# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_9.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_10.qs")
output_hhms <- paste0("households.qs")

## Save household data.
current_date <- Sys.Date()
output_hhms_date <- paste(current_date, output_hhms, sep = "_")
output_data <- file.path(dir_data_process, output_name)
output_data_hhms <- file.path("data/clean", output_hhms)
output_data_hhms_date <- file.path("data/clean/archive", output_hhms_date)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Map objects for labels --------------------------------------------------

YesNoNA_Ind = function(x)
{
  ifelse(x == "Yes", 1,
         ifelse(x == "No", 0, NA))
}



# Participants ------------------------------------------------------------
part_cols <- grep("part", names(dt), value = TRUE)
print(paste0("Participant vars: ", length(part_cols)))

# Household members -------------------------------------------------------
hh_cols <- grep("hh", names(dt), value = TRUE)
print(paste0("Household vars: ", length(hh_cols)))


# Locations ---------------------------------------------------------------
loc_cols <- grep("area|region", names(dt), value = TRUE)
print(paste0("Location vars: ", length(loc_cols)))


# Household types ------------------------------------------------------

## Households types used to be one variable now multiple
## Couple dependent children
## Children under 18 
dt[hh_type_partner == "Yes" &   
     (hh_type_child_under_18 == "Yes"  |
        hh_type_grandchild_under_18 == "Yes" |
        hh_type_siblings_under_18 == "Yes"
     ),
   hh_type := "Couple with dependent children"
]

dt[hh_type == "Couple with dependent children aged 0-17",
   hh_type := "Couple with dependent children",
]

## Couple independent children
dt[hh_type_partner == "Yes" & 
     (hh_type_child_18_plus == "Yes" |
        hh_type_siblings_18_plus == "Yes"  |
        hh_type_grandchild_18_plus == "Yes"
     ) &
     (hh_type_child_under_18 == "No"  &
        hh_type_grandchild_under_18 == "No" &
        hh_type_siblings_under_18 == "No"
     ),
   hh_type := "Couple with independent children only"
]

## Couple with no children
dt[hh_type_partner == "Yes" &   
     hh_type_child_18_plus == "No" &
     hh_type_siblings_18_plus == "No" &
     hh_type_grandchild_18_plus == "No" &
     hh_type_child_under_18 == "No"  &
     hh_type_grandchild_under_18 == "No" &
     hh_type_siblings_under_18 == "No",
   hh_type := "Couple with no children"
]

## Lone parent with dependent children
dt[hh_type_partner == "No" &   
     (hh_type_child_under_18 == "Yes"  |
        hh_type_grandchild_under_18 == "Yes" |
        hh_type_siblings_under_18 == "Yes"
     ),
   hh_type := "Lone parent with dependent children"
]

dt[hh_type == "Lone parent with dependent children aged 0-17",
   hh_type := "Lone parent with dependent children",
]

## Lone parent independent children
dt[hh_type_partner == "Yes" &   
     (hh_type_child_18_plus == "Yes" |
        hh_type_siblings_18_plus == "Yes"  |
        hh_type_grandchild_18_plus == "Yes"
     ) &
     (hh_type_child_under_18 == "No"  &
        hh_type_grandchild_under_18 == "No" &
        hh_type_siblings_under_18 == "No"
     ),
   hh_type := "Lone parent with independent children only"]


## Households containing two or more families
dt[(hh_type_older_relatives == "Yes" |  
      hh_type_other_relative == "Yes" )&
     hh_type_non_relative  == "No",
   hh_type := "Households containing two or more families"]

dt[hh_type == "Households containing two or more families with children aged 0-17",
   hh_type := "Households containing two or more families",
]

## Two or more non-family adults
dt[hh_type_non_relative == "Yes" &
     hh_type_older_relatives == "No" &  
     hh_type_other_relative == "No",
   hh_type := "Two or more non-family adults"]


dt[is.na(hh_type), hh_type := "Other"]



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


# Household member school type and whether contact ------------------------------------------------

dt[, hhm_student_college := YesNoNA_Ind(hhm_student_college)]
dt[, hhm_student_nursery := YesNoNA_Ind(hhm_student_nursery)]
dt[, hhm_student_school := YesNoNA_Ind(hhm_student_school)]
dt[, hhm_contact_yn := YesNoNA_Ind(hhm_contact_yn)]
dt[, hhm_student_university := YesNoNA_Ind(hhm_student_university)]

## Revisit - what categories to use
dt[, table(hhm_student)]

# Symptoms ----------------------------------------------------------------

dt[, hhm_symp_ache := YesNoNA_Ind(hhm_symp_ache)]
dt[, hhm_symp_bn := YesNoNA_Ind(hhm_symp_bn)]
dt[, hhm_symp_bodyaches := YesNoNA_Ind(hhm_symp_bodyaches)]
dt[, hhm_symp_congestion := YesNoNA_Ind(hhm_symp_congestion)]
dt[, hhm_symp_cough := YesNoNA_Ind(hhm_symp_cough)]
dt[, hhm_symp_dk := YesNoNA_Ind(hhm_symp_dk)]
dt[, hhm_symp_fatigue := YesNoNA_Ind(hhm_symp_fatigue)]
dt[, hhm_symp_fever := YesNoNA_Ind(hhm_symp_fever)]
dt[, hhm_symp_headache := YesNoNA_Ind(hhm_symp_headache)]
dt[, hhm_symp_loss_senses := YesNoNA_Ind(hhm_symp_loss_senses)]
dt[, hhm_symp_no_answer := YesNoNA_Ind(hhm_symp_no_answer)]
dt[, hhm_symp_none := YesNoNA_Ind(hhm_symp_none)]
dt[, hhm_symp_sob := YesNoNA_Ind(hhm_symp_sob)]
dt[, hhm_cont_adm_hosp := YesNoNA_Ind(hhm_cont_adm_hosp)]
dt[, hhm_symp_sore_throat := YesNoNA_Ind(hhm_symp_sore_throat)]
dt[, hhm_symp_st := YesNoNA_Ind(hhm_symp_st)]
dt[, hhm_symp_tired := YesNoNA_Ind(hhm_symp_tired)]

# Avoid work -------------------------------------------------------------

dt[, hhm_avoid_work_reason_covidcarer_outside := YesNoNA_Ind(hhm_avoid_work_reason_covidcarer_outside)]
dt[, hhm_avoid_work_reason_hh_isolation := YesNoNA_Ind(hhm_avoid_work_reason_hh_isolation)]
dt[, hhm_avoid_work_reason_hh_quarantine := YesNoNA_Ind(hhm_avoid_work_reason_hh_quarantine)]
dt[, hhm_avoid_work_reason_other := YesNoNA_Ind(hhm_avoid_work_reason_other)]
dt[, hhm_avoid_work_reason_other_illness := YesNoNA_Ind(hhm_avoid_work_reason_other_illness)]
dt[, hhm_avoid_work_reason_othercarer_outside := YesNoNA_Ind(hhm_avoid_work_reason_othercarer_outside)]
dt[, hhm_avoid_work_reason_school_closure := YesNoNA_Ind(hhm_avoid_work_reason_school_closure)]
dt[, hhm_avoid_work_reason_self_isolation := YesNoNA_Ind(hhm_avoid_work_reason_self_isolation)]
dt[, hhm_avoid_work_reason_self_quarantine := YesNoNA_Ind(hhm_avoid_work_reason_self_quarantine)]
dt[, hhm_avoid_work_school_14day_quar := YesNoNA_Ind(hhm_avoid_work_school_14day_quar)]
dt[, hhm_avoid_work_school_7day_iso := YesNoNA_Ind(hhm_avoid_work_school_7day_iso)]
dt[, hhm_avoid_work_school_caring_coivd_not_confirmed := YesNoNA_Ind(hhm_avoid_work_school_caring_coivd_not_confirmed)]
dt[, hhm_avoid_work_school_caring_covid_confirmed := YesNoNA_Ind(hhm_avoid_work_school_caring_covid_confirmed)]
dt[, hhm_avoid_work_school_child_home := YesNoNA_Ind(hhm_avoid_work_school_child_home)]
dt[, hhm_avoid_work_school_illnes := YesNoNA_Ind(hhm_avoid_work_school_illnes)]
dt[, hhm_avoid_work_school_other := YesNoNA_Ind(hhm_avoid_work_school_other)]

# Who will look after children when school closed -------------------------------------------------------------
dt[, hhm_close_childcare_grandparent := YesNoNA_Ind(hhm_close_childcare_grandparent)]
dt[, hhm_close_childcare_neighbour_friend := YesNoNA_Ind(hhm_close_childcare_neighbour_friend)]
dt[, hhm_close_childcare_not_required := YesNoNA_Ind(hhm_close_childcare_not_required)]
dt[, hhm_close_childcare_other := YesNoNA_Ind(hhm_close_childcare_other)]
dt[, hhm_close_childcare_parent_annual_leave := YesNoNA_Ind(hhm_close_childcare_parent_annual_leave)]
dt[, hhm_close_childcare_parent_carer_leave := YesNoNA_Ind(hhm_close_childcare_parent_carer_leave)]
dt[, hhm_close_childcare_parent_part_time_work := YesNoNA_Ind(hhm_close_childcare_parent_part_time_work)]
dt[, hhm_close_childcare_parent_unemployed := YesNoNA_Ind(hhm_close_childcare_parent_unemployed)]
dt[, hhm_close_childcare_parent_unpaid_leave := YesNoNA_Ind(hhm_close_childcare_parent_unpaid_leave)]
dt[, hhm_close_childcare_parent_wfh := YesNoNA_Ind(hhm_close_childcare_parent_wfh)]
dt[, hhm_close_childcare_school := YesNoNA_Ind(hhm_close_childcare_school)]
dt[, hhm_close_childcare_sibling := YesNoNA_Ind(hhm_close_childcare_sibling)]
dt[, hhm_close_childcare_sitter_paid := YesNoNA_Ind(hhm_close_childcare_sitter_paid)]
dt[, hhm_close_childcare_sitter_unpaid := YesNoNA_Ind(hhm_close_childcare_sitter_unpaid)]

# Negative impact of school closureed -------------------------------------------------------------
dt[, hhm_neg_annual_leave := YesNoNA_Ind(hhm_neg_annual_leave)]
dt[, hhm_neg_dont_know := YesNoNA_Ind(hhm_neg_dont_know)]
dt[, hhm_neg_no_carer_leave := YesNoNA_Ind(hhm_neg_no_carer_leave)]
dt[, hhm_neg_no_paid_by_employer := YesNoNA_Ind(hhm_neg_no_paid_by_employer)]
dt[, hhm_neg_no_paid_by_government := YesNoNA_Ind(hhm_neg_no_paid_by_government)]
dt[, hhm_neg_no_wfh := YesNoNA_Ind(hhm_neg_no_wfh)]
dt[, hhm_neg_prefer_not_answer := YesNoNA_Ind(hhm_neg_prefer_not_answer)]
dt[, hhm_neg_yes_lost_all_income := YesNoNA_Ind(hhm_neg_yes_lost_all_income)]
dt[, hhm_neg_yes_other := YesNoNA_Ind(hhm_neg_yes_other)]
dt[, hhm_neg_yes_partial_pay_employer := YesNoNA_Ind(hhm_neg_yes_partial_pay_employer)]
dt[, hhm_neg_yes_partial_pay_government := YesNoNA_Ind(hhm_neg_yes_partial_pay_government)]

## How did the children get looked after?
dt[, hhm_not_attend_childcare_grandparent := YesNoNA_Ind(hhm_not_attend_childcare_grandparent)]
dt[, hhm_not_attend_childcare_neighbour_friend := YesNoNA_Ind(hhm_not_attend_childcare_neighbour_friend)]
dt[, hhm_not_attend_childcare_not_required := YesNoNA_Ind(hhm_not_attend_childcare_not_required)]
dt[, hhm_not_attend_childcare_other := YesNoNA_Ind(hhm_not_attend_childcare_other)]
dt[, hhm_not_attend_childcare_parent_annual_leave := YesNoNA_Ind(hhm_not_attend_childcare_parent_annual_leave)]
dt[, hhm_not_attend_childcare_parent_carer_leave := YesNoNA_Ind(hhm_not_attend_childcare_parent_carer_leave)]
dt[, hhm_not_attend_childcare_parent_part_time_work := YesNoNA_Ind(hhm_not_attend_childcare_parent_part_time_work)]
dt[, hhm_not_attend_childcare_parent_unemployed := YesNoNA_Ind(hhm_not_attend_childcare_parent_unemployed)]
dt[, hhm_not_attend_childcare_parent_unpaid_leave := YesNoNA_Ind(hhm_not_attend_childcare_parent_unpaid_leave)]
dt[, hhm_not_attend_childcare_parent_wfh := YesNoNA_Ind(hhm_not_attend_childcare_parent_wfh)]
dt[, hhm_not_attend_childcare_school_care := YesNoNA_Ind(hhm_not_attend_childcare_school_care)]
dt[, hhm_not_attend_childcare_sibling := YesNoNA_Ind(hhm_not_attend_childcare_sibling)]
dt[, hhm_not_attend_childcare_sitter_paid := YesNoNA_Ind(hhm_not_attend_childcare_sitter_paid)]
dt[, hhm_not_attend_childcare_sitter_unpaid := YesNoNA_Ind(hhm_not_attend_childcare_sitter_unpaid)]

# HHM visiting or seeking health help -------------------------------------
dt[, hhm_visit_ae := YesNoNA_Ind(hhm_visit_ae)]
dt[, hhm_visit_gp := YesNoNA_Ind(hhm_visit_gp)]
dt[, hhm_visit_urgent := YesNoNA_Ind(hhm_visit_urgent)]
dt[, hhm_visit_testing := YesNoNA_Ind(hhm_visit_testing)]
dt[, hhm_phone_gp := YesNoNA_Ind(hhm_phone_gp)]
dt[, hhm_seek_gov_info := YesNoNA_Ind(hhm_seek_gov_info)]


# Map questions -----------------------------------------------------------
## Revisit
dt[, table(hhm_covid_test_recent)]
dt[, table(hhm_covid_test_result)] ##? Not in the data?
names(dt)
dt[, table(hhm_covid_contact)] ## ? Not in the data?
dt[, table(hhm_employstatus)]
dt[, table(hhm_high_risk)]

##  Revisit - yes no  prefer not to say

#dt[, table(hhm_isolate)]
#dt[, table(hhm_isolate_atleast_one_day)]
#dt[, table(hhm_educaton_closed)]
#dt[, table(hhm_work_closed)]
#dt[, table(hhm_avoid_work_school_other_reason1)]
#dt[, table(hhm_avoid_work_school_other_reason2)]

## Other
#dt[, table(hhm_neg_yes_other_reason)]
#dt[, table(hhm_close_childcare_other_reason)]
#dt[, table(hhm_cont_adm_hosp_other)]
#
#dt[, table(hhm_isolation_end_other)]
#dt[, table(hhm_isolation_start_other)]
#dt[, table(hhm_limit_school)]
#dt[, table(hhm_limit_school_atleast_day)]
#dt[, table(hhm_limit_work)]
#dt[, table(hhm_limit_work_atleast_day)]
#
#dt[, table(hhm_phone_gp_other)]
#dt[, table(hhm_pregnant)]
#dt[, table(hhm_quarantine)]
#dt[, table(hhm_quarantine_end_other)]
#dt[, table(hhm_quarantine_one_day)]
#dt[, table(hhm_quarantine_start_other)]


# Needs to be checked -----------------------------------------------------

## Revisit
#dt[, table(hhm_reaction_no_answer)] ## What does this mean
#dt[, table(hhm_reaction_dk)] ##
#dt[, table(hhm_reaction_none)]
#dt[, table(hhm_seek_gov_info_other)]
#
#
#
#dt[, table(hhm_visit_ae_other)]
#dt[, table(hhm_visit_gp_other)]
#dt[, table(hhm_visit_testing_other)]
#dt[, table(hhm_visit_other)]
#dt[, table(hhm_work_closure_end_other)]
#dt[, table(hhm_work_closure_start_other)]
#



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
             "hhm_flag",
             "part_flag",
             "contact")
hhm_vars <- c(id_vars, hhm_names)
#names(dt)[!names(dt) %in% hhm_vars]

hhms <- dt[hhm_flag == TRUE, ..hhm_vars]
# Do not remove household variables.-------------------------------------------------------------------------

## They will be used in the next script and change to part variables

# Only keep household and participants ------------------------------------

dt <- dt[ part_flag == TRUE]

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Removed household only data'))
print(paste0('Saved: ' , output_name))
# Save household data ---------------------------------------------------------------
qs::qsave(hhms, file = output_data_hhms)
qs::qsave(hhms, file = output_data_hhms_date)
print(paste0('Saved: ' , output_hhms))
print(paste0('Saved: ' , output_hhms_date))
