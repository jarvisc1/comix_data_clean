## Name: dm11_clean_participants_v3.R
## Description: Clean variables nrelated to particiapants
## Input file: combined_10_v3.qs
## Functions:
## Output file: combined_11_v3.qs, part_v3.qs, part_min_v3.qs



# Packages ----------------------------------------------------------------
library(data.table)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')


# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
  latest <-  1 ## Change to zero if you to test all interactively
} else if(args[1] == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Updating ", ifelse(latest==0, "All", "Latest")))

# I/O Data ----------------------------------------------------------------

if(latest == 1){
  input_name <-  paste0("combined_10_v3a.qs")
  output_name <- paste0("combined_11_v3a.qs")
  output_parts <- paste0("part_v3a.qs")
  output_parts_min <- paste0("part_min_v3a.qs")
} else if(latest ==0){
  input_name <-  paste0("combined_10_v3.qs")
  output_name <- paste0("combined_11_v3.qs")
  output_parts <- paste0("part_v3.qs")
  output_parts_min <- paste0("part_min_v3.qs")
}


# I/O Data ----------------------------------------------------------------

input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

## Save participant data
current_date <- Sys.Date()
output_parts_date <- paste(current_date, output_parts, sep = "_")
output_data_parts <- file.path("data/clean", output_parts)
output_data_parts_min <- file.path("data/clean", output_parts_min)
output_data_parts_date <- file.path("data/clean/archive", output_parts_date)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 


# Map objects for labels --------------------------------------------------


map_visits <- c("I intended to visit but chose not to go because of the coronavirus (covid-19) epidemic" = "intended did not reason covid", 
                "I intended to visit but I had to cancel/it was cancelled for reasons unrelated to the coronavirus (covid-19) epidemic" = "intended cancelled not covid", 
                "I intended to visit but it was cancelled because of the coronavirus (covid-19) epidemic" = "intended cancelled due to covid", 
                "No, I did not visit or intend to visit this event or location" = "did not visit or intend to visit", 
                "Yes, I visited this event or location" = "visited",
                "Yes" = "yes",
                "No" = "no")

map_visits_yn <- c("intended did not reason covid" = "no", 
                   "intended cancelled not covid" = "no", 
                   "intended cancelled due to covid" = "no", 
                   "did not visit or intend to visit" = "no", 
                   "visited" = "yes",
                   "Yes" = "yes",
                   "No" = "no",
                   "yes" = "yes",
                   "no" = "no"
)

map_test <- c(
  "Don’t know" = "unknown", 
  "Prefer not to answer"  = "no answer",
  "Not tested" = "not tested", 
  "Tested and the test showed {#i_they.response.label} have or had Coronavirus" = "positive", 
  "Tested, and the test showed {#i_they.response.label} have not had Coronavirus" = "negative", 
  "Yes, and {#im_are.response.label} still waiting to hear the result" = "waiting for result",
  "Tested and the test showed {#i_they.response.label} did have Coronavirus at the time" = "positive", 
  "Tested, and the test showed {#i_they.response.label} did not have Coronavirus" = "negative", 
  "Yes, and {#im_are.response.label} still waiting to hear the result" = "waiting for result"
)

map_attend_work_educ <- c(
  "About once or twice per week" = "1-2 days", 
  "Don’t know" = "unknown", 
  "Every day" = "every day",
  "Most days" = "most days",
  "No days – {#insQ42b.response.label} did not attend {#insQ42bb.response.label} for another reason" = "no days - absent",
  "No days – {#insQ42b.response.label} only did {#insQ42bbbb.response.label} {#insQ42bb.response.label} work/activities at" = "no days - spent at home",
  "No days – {#i_they.response.label} did not work this week for another reason" = "no days - absent", 
  "No days – {#i_they.response.label} only worked from home", "Prefer not to answer" = "no days - wfh",
  "Prefer not to answer" = "no answer"
)

map_status <- c(
  "Don’t know" = "unknown", 
  "Fully open as normal" = "Open",
  "Not applicable – it is closed for the holidays" = "closed for holidays", 
  "Partially open i.e. open some days, or for certain hours, or only open to some children/pupils/students" = "partially open", 
  "Partially open i.e. open some days, or for certain hours, or only open to some members of staff"  = "partially open", 
  "Prefer not to answer" = "not answered",
  "Not applicable – {#i_they.response.label} do not have a workplace" = "no workplace",
  "No, but it was open for my child" = "no but open for my child",
  "Not applicable as it was a weekend/holiday/day off" = "closed - holiday", 
  "Not applicable as it was closed" = "closed", 
  "Yes" = "yes"
)



map_report_contacts <- c(
  "{#child_name.response.value} did not have any contacts" = "no contacts", 
  "{#Chosen_child} did not have any contacts" = "no contacts", 
  "I did not have any contacts" = "no contacts", 
  "I did not individually include every person {#child_name.response.value} had contact with." = "no", 
  "I did not individually include every person {#Chosen_child} had contact with." = "no", 
  "I did not individually include every person I had contact with." = "no", 
  "I individually included every person {#child_name.response.value} had contact with." = "yes", 
  "I individually included every person {#Chosen_child} had contact with." = "yes", 
  "I individually included every person I had contact with." = "yes"
)

map_fm_yn <- c(
  "Yes" = "yes",
  "No" = "no",
  "don't know" = "unknown",
  "0" = "no",
  "1" = "yes"
)


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

# Clean participants ------------------------------------------------------




## Removing spaces and lower case ---------------------------------------------------------

dt[, part_ethnicity := tolower(part_ethnicity)]
dt[, part_ethnicity2 := tolower(part_ethnicity2)]
dt[, part_social_group := gsub("  ", " ", part_social_group)]

# Behaviour and attitudes -------------------------------------------------

## Formatting variables
att_eff_levels <- c("Very effective", "Fairly effective", "Not very effective",
                    "Not at all effective", "Don’t know")
att_levels <- c("Strongly agree", "Tend to agree", "Neither agree nor disagree",
                "Tend to disagree", "Strongly disagree", "Don’t know")
att_can_levels <- c("Very confident", "Fairly confident", "Not very confident",
                    "Not at all confident", "Don’t know")


## Consequences for doing them
dt[, part_att_likely := factor(part_att_likely, levels = att_levels)]
dt[, part_att_serious := factor(part_att_serious, levels = att_levels)]
dt[, part_att_spread := factor(part_att_spread, levels = att_levels)]

# Visits ------------------------------------------------------------------

## Map the vars to more readable answers

visit_names_int <- grep("part_visit", names(dt), value = TRUE)


if(length(visit_names_int)>0){
  map_visits_fn <- function(x) map_visits[x]
  map_visits_yn_fn <- function(x) map_visits_yn[x]
  
  dt[ , (visit_names_int) := lapply(.SD, map_visits_fn), .SDcols = visit_names_int]
  
  visit_names <- gsub("_int", "", visit_names_int)
  ## Create yes no versions
  dt[ , (visit_names) := lapply(.SD, map_visits_yn_fn), .SDcols = visit_names_int]
}


# Could add in don't know to the above ------------------------------------
# dt[, table(part_visit_cinema_not_attend_times_dk)]
# dt[, table(part_visit_concert_not_attend_times_dk)]
# dt[, table(part_visit_pub_not_attend_times_dk)]
# dt[, table(part_visit_restaurant_not_attend_times_dk)]
# dt[, table(part_visit_sportevent_attendee_not_attend_times_dk)]
# dt[, table(part_visit_sportevent_participant_not_attend_times_dk)]
# dt[, table(part_visit_supermarket_not_attend_times_dk)]
# dt[, table(part_visit_religious_event_not_attend_times_dk)]
# 
# dt[, table(part_visit_indoor_event_not_attend_times_reason_1)]
# dt[, table(part_visit_indoor_event_not_attend_times_reason_1_dk)]
# dt[, table(part_visit_indoor_event_not_attend_times_reason_2)]
# dt[, table(part_visit_outdoor_event_not_attend_times_dk)]
# dt[, table(part_visit_outdoor_event_not_attend_times_reason_1)]
# dt[, table(part_visit_outdoor_event_not_attend_times_reason_2)]

# Facemasks --------------------------------------------------------------
dt[, part_face_mask := map_fm_yn[part_face_mask]]
dt[, part_face_mask_cycling := map_fm_yn[part_face_mask_cycling]]
dt[, part_face_mask_everywhere := map_fm_yn[part_face_mask_everywhere]]
dt[, part_face_mask_home := map_fm_yn[part_face_mask_home]]
dt[, part_face_mask_leisure := map_fm_yn[part_face_mask_leisure]]
dt[, part_face_mask_other := map_fm_yn[part_face_mask_other]]
dt[, part_face_mask_other_house := map_fm_yn[part_face_mask_other_house]]
dt[, part_face_mask_outside := map_fm_yn[part_face_mask_outside]]
dt[, part_face_mask_public_transport := map_fm_yn[part_face_mask_public_transport]]
dt[, part_face_mask_supermarkets := map_fm_yn[part_face_mask_supermarkets]]
dt[, part_face_mask_walk_street := map_fm_yn[part_face_mask_walk_street]]
dt[, part_face_mask_work_education := map_fm_yn[part_face_mask_work_education]]


# Tests -------------------------------------------------------------------

dt[, part_antibody_test := map_test[part_antibody_test]]
dt[, part_covid_test_past := map_test[part_covid_test_past]]


# Travel ------------------------------------------------------------------

dt[, part_public_transport_boat := map_fm_yn[part_public_transport_boat]]
dt[, part_public_transport_bus := map_fm_yn[part_public_transport_bus]]
dt[, part_public_transport_no := map_fm_yn[part_public_transport_no]]
dt[, part_public_transport_plane := map_fm_yn[part_public_transport_plane]]
dt[, part_public_transport_taxi_uber := map_fm_yn[part_public_transport_taxi_uber]]
dt[, part_public_transport_train := map_fm_yn[part_public_transport_train]]


# Work --------------------------------------------------------------------

dt[, part_attend_education_week := map_attend_work_educ[part_attend_education_week]]
dt[, part_attend_work_week := map_attend_work_educ[part_attend_work_week]]

dt[, part_attend_education_yesterday := map_fm_yn[part_attend_education_yesterday]]
dt[, part_attend_work_yesterday := map_fm_yn[part_attend_work_yesterday]]
dt[, part_attend_school_yesterday := map_status[part_attend_school_yesterday]]
dt[, part_employstatus := tolower(part_employstatus)]
dt[, part_student_employed := tolower(part_student_employed)]
dt[, part_employed_attends_education := tolower(part_employed_attends_education)]
dt[, part_educationplace_status := map_status[part_educationplace_status]]
dt[, part_workplace_status := map_status[part_workplace_status]]
dt[, part_furloughed := map_fm_yn[part_furloughed]]
dt[, part_isolation_quarantine := map_fm_yn[part_isolation_quarantine]]
dt[, part_pregnant := map_fm_yn[part_pregnant]]
dt[, part_income := tolower(part_income)]
dt[, part_no_contacts := tolower(part_no_contacts)]
dt[, part_reported_all_contacts := map_report_contacts[part_reported_all_contacts]]


## Risk change from personal to all household from survey round 44
risk_names <- grep("part_.*_risk", names(dt), value = TRUE)

if(length(risk_names)>0){
  dt[, part_med_risk_v2 := map_fm_yn[part_med_risk_v2]]	  dt[, part_med_risk_v2_temp := map_fm_yn[part_med_risk_v2]]
  dt[, part_high_risk_v2 := map_fm_yn[part_high_risk_v2]]	  dt[, part_high_risk_v2_temp := map_fm_yn[part_high_risk_v2]]
  dt[, part_high_risk_v2 := NULL]
  dt[, part_med_risk_v2 := NULL]
}




# Class size --------------------------------------------------------------

cut_class <- function(x) {
  cut(as.numeric(x), breaks = c(0,5,10, 15,30, 50, 50000), labels = c("<5", "5-9", "10-14", "15-29", "30-49", "50+"))
}


dt[, part_school_class_size := cut_class(part_school_class_size)]

# Hand washing ------------------------------------------------------------


# Switch hhm vars to be part ----------------------------------------------

dt[, hhm_flag := NULL]

hhmvars_old <- grep("hhm", names(dt), value = TRUE)

hhmvars_new <-  gsub("hhm", "part", hhmvars_old)

hhmvars_old <- hhmvars_old[!hhmvars_new %in% names(dt)]
hhmvars_new <- hhmvars_new[!hhmvars_new %in% names(dt)]


setnames(dt, old = hhmvars_old, new = hhmvars_new, skip_absent = TRUE)

if(length(risk_names)>0){
  dt[, table(part_med_risk_v2)]	  dt[is.na(part_high_risk_v2), part_high_risk_v2 := part_high_risk_v2_temp ]
  dt[is.na(part_med_risk_v2), part_med_risk_v2 := part_med_risk_v2_temp ]
  dt[, part_high_risk_v2_temp := NULL]
  dt[, part_med_risk_v2_temp := NULL]
}

# Create a consistent risk category
dt[, part_high_risk := ifelse(part_high_risk_v2 == "yes" | part_med_risk_v2 == "yes", "yes", "no")]


# Remove variables --------------------------------------------------------

q21vars <- grep("q21", names(dt), value = TRUE)
q23vars <- grep("q23", names(dt), value = TRUE)

vars_remove <- readxl::read_excel('codebook/var_names.xlsx', sheet = "remove_vars")
remove_vars <- c(q21vars, q23vars, vars_remove$remove)
remove_vars <- remove_vars[remove_vars %in% names(dt)]

set(dt, j = remove_vars, value = NULL)


# Filter to relevant columns -------------------------------------------------------

parts_names <- grep("part", names(dt), value = TRUE)
parts_names <- parts_names[parts_names != "parts_nickname_masked"]

id_vars <- c("country",
             "area_2_name", 
             "area_3_name", 
             "panel",
             "wave",
             "date",
             "weekday",
             "part_id",
             "part_uid",
             "part_wave_uid",
             "contact_flag",
             "contact")
parts_vars <- c(id_vars,  parts_names)

vars_names <- c("part_id", 
                "part_uid",
                "part_wave_uid",
                "country",
                "panel", 
                "wave",
                "survey_round",
                "sample_type",
                "date",
                "weekday",
                "area_2_name", 
                "area_3_name", 
                "part_age",
                "part_ethnicity",
                "part_social_group",
                "part_age_group", 
                "part_age_est_min",
                "part_age_est_max",
                "hh_size",
                "hh_size_group"
)

dt_min = dt[, ..vars_names]



# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saving only participant data'))
print(paste0('Saved: ' , output_name))
# Save participant data ---------------------------------------------------------------
qs::qsave(dt, file = output_data_parts)
qs::qsave(dt, file = output_data_parts_date)
qs::qsave(dt_min, file = output_data_parts_min)
print(paste0('Saved: ' , output_parts_min))
print(paste0('Saved: ' , output_parts))
print(paste0('Saved: ' , output_parts_date))



