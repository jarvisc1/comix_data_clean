## Name: dm07_clean_contact_vars_v5.R
## Description: Clean the variables relating to the contact data.
## Input file: combined_7_v5.qs
## Functions:
## Output file: combined_8_v5.qs clean/contacts_v5.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_7_v5.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_8_v5.qs")
output_data <- file.path(dir_data_process, output_name)

## Save contact data
current_date <- Sys.Date()
output_cnts <- paste0("contacts_v5.qs")
output_cnts_date <- paste(current_date, output_cnts, sep = "_")
output_data_cnts <- file.path("data/clean", output_cnts)
output_data_cnts_date <- file.path("data/clean/archive", output_cnts_date)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 


# Remove variables not needed ---------------------------------------------
# Such as market sector and extra variables that shouldn't have been added.

v_remove <- readxl::read_excel('codebook/var_names.xlsx', sheet = "remove_vars")

vars_remove <- names(dt)[names(dt) %in% v_remove$remove]
print(paste0("Removed ", length(vars_remove), " columns"))
set(dt, j = vars_remove, value = NULL)


# Empty contacts ----------------------------------------------------------

## There are excess _i variables from IPSOS which are not useful
set(dt, j = grep(".*_i$", names(dt), value = TRUE), value = NULL)

setkey(dt, country, panel, wave,part_id)


# Remove data that is just for tracking household members -----------------

## Remove household members that are just being tracked.
vars <- c("country", "part_id", "panel", "wave", "row_id", "sample_type", "child_id")
hhcomp <- grep("hhcomp", names(dt), value = TRUE)
vars <- c(vars, hhcomp)

rows_start <- nrow(dt)
missing <- rowSums(!is.na(dt[,.SD, .SDcols = !vars]))==0

## This could be output somewhere if we wanted. 
dt_hhm_tracker <- dt[missing]
dt <- dt[!missing]
print(paste0("Removed ", rows_start-nrow(dt), " empty rows"))

# Map objects for labels --------------------------------------------------

map_survey_sample <- c(
   "Qsample=1 WAVE-TO-WAVE" = "repeated",
   "Qsample=2 FRESH SAMPLE" = "new"
)
map_sample_type <- c(
   "Sampletype=1 Main sample" = "adult",
   "Sampletype=2 Parent sample" = "child"
)

map_minutes <- c(
   "Less than 1 minute" = "<1m",
   "1 minutes or more, but less than 5 minutes" = "<5m",
   "Less than 5 minutes" = "<5m",
   "5 minutes or more, but less than 15 minutes" = "5m-14m",
   "15 minutes or more, but less than 1 hour" = "15m-59m",
   "1 hour or more, but less than 4 hours" = "60m-4h",
   "1 hour or more" = "60m-4h",
   "4 hours or more" = "4h+"
)

map_minutes_min = c(
   "<1m" = 0,
   "<5m" = 0,
   "5m-14m" = 5,
   "15 minutes or more, but less than 1 hour" = 15,
   "60m-4h" = 60,
   "4h+" = 240
)

map_minutes_max = c(
   "<1m" = 1,
   "<5m" = 5,
   "5m-14m" = 15,
   "15 minutes or more, but less than 1 hour" = 60,
   "60m-4h" = 240,
   "4h+" = 1440
)

map_gender <- c(
   "Female" = "female",
   "Male" = "male",
   "In another way" = "other",
   "Prefer not to answer" = NA_character_,
   "3" = NA_character_,
   "4" = NA_character_
)

map_contacts_error <- c(
   "‘individual identified’" = "ind identified",
   "‘potential household member’" = "poten hhm", 
   "‘suspected multiple contact’"= "sus multi",
   "‘suspected non contact’" = "sus non-contact",
   "0" = "ind identified", 
   "individual identified" = "ind identified",
   "multiple names given" = "sus multi", 
   "no contact" =  "sus non-contact", 
   "potential household member" = "poten hhm",
   "suspected multiple contact" = "sus multi", 
   "suspected non contact" =  "sus non-contact"
)

map_type <- c(
   "They are a family member who is not in my household" = "family_non_household",
   "They are someone I work with" = "work",
   "They are someone I go to school, college or university with" = "school",
   "They are a friend" = "friend",
   "They are family members not in our household" = "family_non_household",
   "They are a babysitter, childminder, or nanny" = NA,
   "They are someone they go to nursery, pre-school, school, college or university with" = "school",
   "They are friends" = "friend",
   "They are a client or customer" = "work",
   "They are my spouse/girlfriend/boyfriend/partner" = "partner",
   "They are someone they see at nursery, pre-school, school, college or university" = "school"
)

map_freq <- c(
   "Never met them before" = "never met",
   "Less often than once per month" = "occasional",
   "About once per month" = "1 month",
   "Every 2-3 weeks" = "2-3 weeks",
   "About once or twice a week" = "3-7 days",
   "Every day or almost every day" = "1-2 days"
)

map_report_ind_contacts <- c(
   "{#child_name.response.value} did not have any contacts" = "no contacts", 
   "{#Chosen_child} did not have any contacts" = "no contacts", 
   "I did not have any contacts" = "no contacts", 
   "I did not individually include every person {#child_name.response.value} had contact with." = "all not reported", 
   "I did not individually include every person {#Chosen_child} had contact with." = "all not reported", 
   "I did not individually include every person I had contact with." = "all not reported", 
   "I individually included every person {#child_name.response.value} had contact with." = "reported all", 
   "I individually included every person {#Chosen_child} had contact with." = "reported all", 
   "I individually included every person I had contact with." = "reported all"
)
YesNoNA_Ind = function(x)
{
   ifelse(x == "Yes", 1,
          ifelse(x == "No", 0, NA))
}

YesNoNA = function(x)
{
   ifelse(x == "Yes", TRUE,
          ifelse(x == "No", FALSE, NA))
}




# Label values ------------------------------------------------------------

dt[, survey_round := as.numeric(survey_round)]
dt[, survey_round := first(survey_round), by = .(country, panel, wave)]

dt[, part_uid := paste0(country,"_", part_id)]
dt[, part_wave_uid := paste0(country,"_", panel, wave,"_", part_id)]
dt[, hhld_wave_uid := paste0(country,"_", panel,"_H_", part_id)]


## Gender
dt[, part_gender    := map_gender[part_gender]]
dt[, part_gender_nb := map_gender[part_gender_nb]]
dt[, cnt_gender := map_gender[cnt_gender]]
dt[, hhm_gender := map_gender[hhm_gender]]

## Did participant have contacts
dt[, part_report_ind_contacts := map_report_ind_contacts[part_reported_all_contacts]]

## Fill in participant information
dt[, part_gender := first(part_gender), by = .(part_wave_uid)]
dt[, part_gender_nb := first(part_gender_nb), by = .(part_wave_uid)]
dt[, part_age := first(part_age), by = .(part_wave_uid)]
dt[, currentday := first(currentday), by = .(part_wave_uid)]
dt[, currentmonth := first(currentmonth), by = .(part_wave_uid)]
dt[, currentyear := first(currentyear), by = .(part_wave_uid)]

# Clean Contact dates -----------------------------------------------------------
## Survey date is given as separate day, month, and year
dt[, survey_date := as.Date(paste0(currentyear,"-", currentmonth,"-", currentday ))]

## Create survey days and day when contact happend
dt[, survey_weekday := weekdays(survey_date)]
dt[, date := survey_date - 1]
dt[, weekday := weekdays(date)]
dt[, week := week(date)]
dt[, month := month(date)]
dt[, year := year(date)]
dt[, survey_start_week := min(week, na.rm = T), by = country]

# Identify contacts, participants, household ----------------------------------------------

## Identify contacts, participants, household
## Participants have row id of zero
dt[row_id == 0, part_flag := TRUE]
dt[is.na(part_flag), part_flag := FALSE]

## Household members
## These two lines should achieve the same thing.
dt[row_id ==0 | !is.na(hhm_age_group), hhm := 1]
dt[is.na(hhm_age_group), hhm := 0]
dt[row_id == 0 | hhm_contact == "Yes" | !is.na(hhm_age_group), hhm_flag := TRUE]
dt[is.na(hhm_flag), hhm_flag := FALSE]


## Contacts are not participants, mass contact have a missing row_id
## Contacts are also household member with hhm_contact == "Yes"
## Fill in household member contacts to be no for all contacts except household members

dt[is.na(row_id) | (is.na(hhm_contact) & row_id != 0), hhm_contact := "No"]
dt[!is.na(cnt_mass), contact_flag := TRUE]
dt[is.na(contact_flag), contact_flag := FALSE]

# Physical contacts -------------------------------------------------------

## Variable changed through panels

dt[grepl("Physical contact \\(any sort|Yes", cnt_phys), cnt_phys := "Yes" ]
dt[grepl("Non-physical contact|No", cnt_phys), cnt_phys := "No"]
dt[grepl("Prefer not to answer", cnt_phys), cnt_phys := "No"]
## Mass contact are treated as non-physical
dt[cnt_mass == "mass", cnt_phys := "No"]

# Participant's age ---------------------------------------------------------------------

## Put the min and max of the children's age's into a min and max ver.
## Then make participant's age numeric and have missing for kids.


## We are changing string to numeric and it drops NA's switch these warnings off
oldw <- getOption("warn")
options(warn = -1)


dt[, part_age_int := as.numeric(part_age)]
dt[part_age == "Prefer not to answer", part_age := NA]

dt[, part_age_est_min := part_age_int]
dt[, part_age_est_max := part_age_int]
dt[part_age == "Under 1", part_age_est_min := 0]
dt[part_age == "Under 1", part_age_est_max := 1]

dt[is.na(part_age_est_min), part_age_est_min := as.numeric(str_replace_all(part_age, "-.*", ""))]
dt[is.na(part_age_est_max), part_age_est_max := as.numeric(str_replace_all(part_age, ".*-", ""))]
dt[is.na(part_age_est_min), part_age_est_min := as.numeric(str_replace_all(part_age, "\\+", ""))]
dt[is.na(part_age_est_max), part_age_est_max := as.numeric(str_replace_all(part_age, ".*\\+", "120"))]

## Switch warnings back on
options(warn = oldw)

# Children's age groups -----------------------------------------------

## Acceptable child age groups
child_age_groups <- c("0-4", "5-11", "12-17")

## Make sample_type present in all questions
dt[, sample_type := first(sample_type), by = part_id]
dt[sample_type == "child" & part_age_est_max == 1,                        part_age_est_max := 4]
dt[sample_type == "child" & part_age_est_min > 0 &  part_age_est_max <5,  part_age_est_min := 0]
dt[sample_type == "child" & part_age_est_min > 0 &  part_age_est_max <5,  part_age_est_max := 4]
dt[sample_type == "child" & part_age_est_min > 4 &  part_age_est_max <12, part_age_est_min := 5]
dt[sample_type == "child" & part_age_est_min > 4 &  part_age_est_max <12, part_age_est_max := 11]
dt[sample_type == "child" & part_age_est_min > 11 & part_age_est_max <18, part_age_est_min := 12]
dt[sample_type == "child" & part_age_est_min > 11 & part_age_est_max <18, part_age_est_max := 17]

dt[sample_type == "child" & part_age_est_min > 17,  part_age_est_min := NA_real_]
dt[sample_type == "child" & part_age_est_max > 17,  part_age_est_max := NA_real_]

## Cut up the age groups into categories
## Min
dt[between(part_age_est_min,  0, 4)   , age_min :=  0 ]
dt[between(part_age_est_min,  5,11)   , age_min :=  5 ]
dt[between(part_age_est_min,  12,17)  , age_min :=  12]
dt[between(part_age_est_min,  18,29)  , age_min :=  18]
dt[between(part_age_est_min,  30,39)  , age_min :=  30]
dt[between(part_age_est_min,  40,49)  , age_min :=  40]
dt[between(part_age_est_min,  50,59)  , age_min :=  50]
dt[between(part_age_est_min,  60,69)  , age_min :=  60]
dt[between(part_age_est_min,  70,120) , age_min :=  70]
## Max
dt[between(part_age_est_max,  0, 4)   , age_max :=  4 ]
dt[between(part_age_est_max,  5,11)   , age_max :=  11 ]
dt[between(part_age_est_max,  12,17)  , age_max :=  17]
dt[between(part_age_est_max,  18,29)  , age_max :=  29]
dt[between(part_age_est_max,  30,39)  , age_max :=  39]
dt[between(part_age_est_max,  40,49)  , age_max :=  49]
dt[between(part_age_est_max,  50,59)  , age_max :=  59]
dt[between(part_age_est_max,  60,69)  , age_max :=  69]
dt[between(part_age_est_max,  70,120) , age_max :=  120]

dt[!is.na(age_min), part_age_group := paste0(age_min, "-", age_max)]

dt[, part_age := part_age_int]
dt[, part_age_int := NULL]
dt[, age_min := NULL]
dt[, age_max := NULL]



# Contact's age -----------------------------------------------------------

# Fill in contact age with hhm age if a contact
dt[hhm_contact == "Yes", cnt_age := hhm_age_group]
dt[hhm_contact == "Yes", cnt_gender := hhm_gender]

# Remove non contacts -----------------------------------------------------

## Base on text from IPSOS
dt[, contact := map_contacts_error[contact]]
dt <- dt[!contact %in% c("sus multi", "sus non-contact", "poten hhm")]
#dt[, contact := NULL]

## Based on inaccurate age
## Remove the repeat contact's that are present in the ages.
dt[, remove_row := str_replace_all(cnt_age, ".*me.*|.*person.*|.*This.*","not_real")]

## Remove no contact ages such as "this is me"
dt <- dt[remove_row != "not_real" | is.na(cnt_age)]
dt[, remove_row := NULL]

# Create min and max age --------------------------------------------------

## We are changing string to numeric and it drops NA's switch these warnings off
oldw <- getOption("warn")
options(warn = -1)


dt[, cnt_age_est_min := as.numeric(cnt_age)]
dt[, cnt_age_est_max := as.numeric(cnt_age)]
dt[cnt_age == "Don’t know", cnt_age_est_min := 0]
dt[cnt_age == "Don’t know", cnt_age_est_max := 120]
dt[cnt_age == "Prefer not to answer", cnt_age_est_min := 0]
dt[cnt_age == "Prefer not to answer", cnt_age_est_max := 120]
dt[cnt_age == "Under 1", cnt_age_est_min := 0]
dt[cnt_age == "Under 1", cnt_age_est_max := 1]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_age_est_min := as.numeric(str_replace_all(cnt_age, "\\+", ""))]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_age_est_max := 120]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_age_est_min := as.numeric(str_replace_all(cnt_age, "-[0-9]+", ""))]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_age_est_max := as.numeric(str_replace_all(cnt_age, "[0-9]+-", ""))]

## Switch warnings back on
options(warn = oldw)


## Min
dt[between(cnt_age_est_min,  0, 4)   , age_min :=  0 ]
dt[between(cnt_age_est_min,  5,11)   , age_min :=  5 ]
dt[between(cnt_age_est_min,  12,17)  , age_min :=  12]
dt[between(cnt_age_est_min,  18,29)  , age_min :=  18]
dt[between(cnt_age_est_min,  30,39)  , age_min :=  30]
dt[between(cnt_age_est_min,  40,49)  , age_min :=  40]
dt[between(cnt_age_est_min,  50,59)  , age_min :=  50]
dt[between(cnt_age_est_min,  60,69)  , age_min :=  60]
dt[between(cnt_age_est_min,  70,120) , age_min :=  70]
## Max
dt[between(cnt_age_est_max,  0, 4)   , age_max :=  4 ]
dt[between(cnt_age_est_max,  5,11)   , age_max :=  11 ]
dt[between(cnt_age_est_max,  12,17)  , age_max :=  17]
dt[between(cnt_age_est_max,  18,29)  , age_max :=  29]
dt[between(cnt_age_est_max,  30,39)  , age_max :=  39]
dt[between(cnt_age_est_max,  40,49)  , age_max :=  49]
dt[between(cnt_age_est_max,  50,59)  , age_max :=  59]
dt[between(cnt_age_est_max,  60,69)  , age_max :=  69]
dt[between(cnt_age_est_max,  70,120) , age_max :=  120]

dt[!is.na(age_min), cnt_age_group := paste0(age_min, "-", age_max)]
dt[,age_min := NULL]
dt[,age_max := NULL]

# Contact time ------------------------------------------------------------

## We started by asking for hours and minutes but changed to categories
## Harmonise the categories.
dt[, cnt_total_time := map_minutes[cnt_total_time]]

cnt_tot_time_lev <- c("<1m", "<5m", "5m-14m", "15m-59m",  "60m-4h", "4h+")
dt[, cnt_total_time := factor(cnt_total_time, levels = cnt_tot_time_lev)]

# Contact relations --------------------------------------------------------

dt[, cnt_type := map_type[cnt_type]]
dt[hhm_contact == "Yes", cnt_type := "household"]

dt[, cnt_frequency := map_freq[cnt_frequency]]
cnt_freq_lev <- c("1-2 days", "3-7 days", "2-3 weeks", "1 month", "occasional", "never met")
dt[, cnt_frequency := factor(cnt_frequency, levels = cnt_freq_lev)]

# Contacts settings ----------------------------------------------------------
dt[, cnt_home := YesNoNA_Ind(cnt_home)]
dt[, cnt_work := YesNoNA_Ind(cnt_work)]
dt[, cnt_school := YesNoNA_Ind(cnt_school)]
dt[, cnt_phys := YesNoNA_Ind(cnt_phys)]
dt[, cnt_outside_other := YesNoNA_Ind(cnt_outside_other)]
dt[, cnt_other_house := YesNoNA_Ind(cnt_other_house)]
dt[, cnt_health_facility := YesNoNA_Ind(cnt_health_facility)]
dt[, cnt_public_transport := YesNoNA_Ind(cnt_public_transport)]
dt[, cnt_salon := YesNoNA_Ind(cnt_salon)]
dt[, cnt_shop := YesNoNA_Ind(cnt_shop)]
dt[, cnt_sport := YesNoNA_Ind(cnt_sport)]
dt[, cnt_supermarket := YesNoNA_Ind(cnt_supermarket)]
dt[, cnt_worship := YesNoNA_Ind(cnt_worship)]
dt[, cnt_bar_rest := YesNoNA_Ind(cnt_bar_rest)]
# dt[, cnt_public_market := YesNoNA_Ind(cnt_public_market)] ## yes for EU
dt[, cnt_other_place := YesNoNA_Ind(cnt_other_place)]
dt[, cnt_other := YesNoNA_Ind(cnt_other)]


dt[, cnt_prec_none := YesNoNA_Ind(cnt_prec_none)]
dt[, cnt_prec_dk := YesNoNA_Ind(cnt_prec_dk)]
dt[, cnt_prec_1_and_half_m_plus := YesNoNA_Ind(cnt_prec_1_and_half_m_plus)]
# dt[, cnt_prec_1m_plus := YesNoNA_Ind(cnt_prec_1m_plus)]
# dt[, cnt_prec_within_1_and_half_m := YesNoNA_Ind(cnt_prec_within_1_and_half_m)]
dt[, cnt_prec_mask := YesNoNA_Ind(cnt_prec_mask)]
dt[, cnt_prec_wash_before := YesNoNA_Ind(cnt_prec_wash_before)]
dt[, cnt_prec_wash_after := YesNoNA_Ind(cnt_prec_wash_after)]
dt[, cnt_prec_prefer_not_to_say := YesNoNA_Ind(cnt_prec_prefer_not_to_say)]
dt[, cnt_household := YesNoNA_Ind(hhm_contact)]

if ("be" %in% dt$country) {
   both_indoors_outdoors <- "Both indoors and outdoors"
   
   dt[cnt_indoor_outdoor == "Don’t know", cnt_inside_outside_dk := 1]
   dt[cnt_indoor_outdoor != "Don’t know" | is.na(cnt_indoor_outdoor), cnt_inside_outside_dk := 0]
   dt[cnt_indoor_outdoor == "Don’t know", cnt_inside := NA]
   dt[cnt_indoor_outdoor == "Don’t know", cnt_outside := NA]
   dt[, cnt_inside := 
         ifelse(cnt_indoor_outdoor %in% c("Indoors", both_indoors_outdoors), 1, 0)]
   dt[, cnt_outside := 
         ifelse(cnt_indoor_outdoor %in% c("Outdoors", both_indoors_outdoors), 1, 0)]
} else{
   
   dt[, cnt_inside := YesNoNA_Ind(cnt_inside)]
   dt[, cnt_outside := YesNoNA_Ind(cnt_outside)]
}


dt[is.na(cnt_prec), cnt_prec := fifelse(cnt_prec_none == 0, "Yes", "No")]
dt[, cnt_prec_yn := cnt_prec]
dt[, cnt_prec := YesNoNA_Ind(cnt_prec_yn)]

dt[contact_flag & cnt_home == 1, cnt_main_type := "Home"]
dt[contact_flag & cnt_home == 0 & cnt_work == 1 & sample_type == "child", cnt_main_type := "Work"]
dt[contact_flag & cnt_home == 0 & cnt_work == 0 & cnt_school == 1 & sample_type == "child", cnt_main_type := "School"]
dt[contact_flag & cnt_home == 0 & cnt_work == 1 & sample_type == "adult", cnt_main_type := "Work"]
dt[contact_flag & cnt_home == 0 & cnt_work == 0 & cnt_school == 1 & sample_type == "adult", cnt_main_type := "School"]

dt[contact_flag & cnt_home == 0 & cnt_work == 0 & cnt_school == 0, cnt_other := 1]
dt[contact_flag == TRUE & is.na(cnt_other), cnt_other := 0]
dt[cnt_other == 1, cnt_main_type := "Other"]


# Filter to contact data -------------------------------------------------------

cnt_names <- grep("cnt", names(dt), value = TRUE)
cnt_names <- cnt_names[cnt_names != "cnt_nickname_masked"]
cnt_early <- c("cnt_age_group", "cnt_age_est_min","cnt_age_est_max",
               "cnt_household",
               "cnt_mass", "cnt_phys") 
cnt_names <- cnt_names[!cnt_names %in% cnt_early]
id_vars <- c("part_id",
             "part_uid",
             "part_wave_uid",
             "hhld_wave_uid",
             "date",
             "weekday",
             "survey_round",
             "country",
             "panel",
             "wave",
             "contact_flag",
             "contact" 
             )
cnt_vars <- c(id_vars, cnt_early, cnt_names)

contacts <- dt[contact_flag == TRUE, ..cnt_vars]


# Remove empty contacts that shouldn't be there ---------------------------

# Remove Contacts without any information - not actually contacts
rows_start <- nrow(contacts)

missing <- rowSums(!is.na(contacts[,.SD, .SDcols = !id_vars]))==0

contacts <- contacts[!missing]
print(paste0("Removed ", rows_start-nrow(contacts), " empty rows"))

# Remove contact variables from main data.-------------------------------------------------------------------------

cnt_vars_remove <- c(cnt_early, cnt_names)
set(dt,  j = cnt_vars_remove, value = NULL)

# Only keep household and participants ------------------------------------

dt <- dt[ hhm_flag == TRUE]

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Removed contact only data'))
print(paste0('Saved: ' , output_name))
# Save contact data ---------------------------------------------------------------
qs::qsave(contacts, file = output_data_cnts)
qs::qsave(contacts, file = output_data_cnts_date)
print(paste0('Saved: ' , output_cnts))
print(paste0('Saved: ' , output_cnts_date))

