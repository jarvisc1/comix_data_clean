## Name: dm_clean_existing_vars.R
## Description: Run checks and proces variables already present in the data.
## Input file: dirty_combine_5.qs
## Functions:
## Output file: checked_combine_6.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate)
library(stringr)


# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("dirty_combine_5.qs")
output_name <- paste0("checked_combine_6.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

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
  "Less than 5 minutes" = "<5m",
  "5 minutes or more, but less than 15 minutes" = "5m-14m",
  "15 minutes or more, but less than 1 hour" = "15m-59m",
  "1 hour or more, but less than 4 hours" = "60m-4h",
  "4 hours or more" = "4h+"
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

map_gender <- c(
  "Female" = "female",
  "Male" = "male",
  "In another way" = "other",
  "Prefer not to answer" = NA_character_,
  "3" = NA_character_,
  "4" = NA_character_
)
map_YesNoPNtA <- c(
  "Yes" = "yes",
  "No" = "no",
  "Sometimes" = "sometimes",
  "Prefer not to answer" = NA_character_
)

# Map "Yes", "No", NA to logical
YesNoNA <- function(x)
{
  fifelse(x == "Yes", TRUE,
         fifelse(x == "No", FALSE, NA))
}

# Map "Yes", "No", NA to 1/0/NA
YesNoNA_Ind <- function(x)
{
  fifelse(x == "Yes", 1,
         fifelse(x == "No", 0, NA_real_))
}


# Clean participant id ----------------------------------------------------

## The same participants ID are used for each panel and country.
## We do not anticipate a panel having more than 10,000 people.
## Start at 10,000 and add 10,000 for each panel. 
## B starts from 20,000
## C starts from 30,000

dt[part_id < 10000, part_id := part_id + 10000*as.numeric(factor(panel, LETTERS))]

# Remove variables --------------------------------------------------------

dt[, cultureinfo := NULL]
dt[, data_acum := NULL]
dt[, part_employ_type := NULL]
dt[, main_intro_screen := NULL]
dt[, privacypolicy_insert := NULL]
dt[, quotagerange := NULL]
dt[, sniffer_device_type_final := NULL]
dt[, sniffer_device_type_initial := NULL]
dt[, survey_boost := NULL]
dt[, survey_main := NULL]

# Label values ------------------------------------------------------------

## Gender
dt[, part_gender    := map_gender[part_gender]]
dt[, part_gender_nb := map_gender[part_gender_nb]]
dt[, cnt_gender := map_gender[cnt_gender]]
dt[, hhm_gender := map_gender[hhm_gender]]

## Survey types
dt[, sample_type := map_sample_type[sample_type]]
## Panel A for BE, NL, and NO are all Adults
dt[ country %in% c("be", "nl", "no") & panel == "A", sample_type := "adult"]
## Panel C, D for UK are children
dt[ country == "uk" & panel %in% c("C", "D"), sample_type := "child"]

## Repeated or new participant
dt[, survey_sample := map_survey_sample[survey_sample]]


# Label contacts ----------------------------------------------------------------

cnt_cols <- grep("cnt", names(dt), value = TRUE)
print(paste0("Contacts vars: ", length(cnt_cols)))

cnt_settings_cols <- c(
  "cnt_home",
  "cnt_sport",
  "cnt_outside_other",
  "cnt_otheryn",
  "cnt_other_house",
  "cnt_work",
  "cnt_worship",
  "cnt_public_transport",
  "cnt_school",
  "cnt_supermarket",
  "cnt_shop",
  "cnt_leisure",
  "cnt_health_facility",
  "cnt_salon",
  "cnt_public_market"
)

# Clean to zero, one, NA 
dt[,
   (cnt_settings_cols) :=
     lapply(.SD, YesNoNA_Ind),
   .SDcols = cnt_settings_cols]

# Clean to true false
dt[, cnt_inside  := YesNoNA(cnt_inside)]
dt[, cnt_outside := YesNoNA(cnt_outside)]

## Contact type
dt[, hhm_contact_yn := ifelse(hhm_contact_yn == "No" | is.na(hhm_contact_yn), "no", "yes")]
dt[, cnt_type := ifelse(hhm_contact_yn == "yes", "household", map_type[cnt_type])]
dt[, cnt_phys := YesNoNA(cnt_phys)]
dt[, cnt_frequency := map_freq[cnt_frequency]]

## Precautions
dt[, cnt_multiple_contacts_work_precautions := map_YesNoPNtA[cnt_multiple_contacts_work_precautions]]
dt[, cnt_multiple_contacts_school_precautions := map_YesNoPNtA[cnt_multiple_contacts_school_precautions]]
dt[, cnt_multiple_contacts_other_precautions := map_YesNoPNtA[cnt_multiple_contacts_other_precautions]]
## Precautions true false, want to rename these as precautions
dt[, cnt_precautions_none := YesNoNA(cnt_precautions_none)]
dt[, cnt_two_metres_plus := YesNoNA(cnt_two_metres_plus)]
dt[, cnt_one_metre_plus := YesNoNA(cnt_one_metre_plus)]
dt[, cnt_within_one_metre := YesNoNA(cnt_within_one_metre)]
dt[, cnt_mask := YesNoNA(cnt_mask)]
dt[, cnt_wash_before := YesNoNA(cnt_wash_before)]
dt[, cnt_wash_after := YesNoNA(cnt_wash_after)]
dt[, cnt_precautions_prefer_not_to_say := YesNoNA(cnt_precautions_prefer_not_to_say)]

# Time spent
## We started by asking for hours and minutes but changed to categories
## Harmonise the categories.
dt[, cnt_total_time := map_minutes[cnt_total_time]]
dt[, temp_times := (60 * as.numeric(cnt_hours)) + as.numeric(cnt_mins)]
dt[, temp_times := cut(temp_times, 
                       breaks = c(0,5,15,60,240, 1000),
                       labels = c("<5m","5m-14m","15m-59m","60m-4h","4h+"),
                       right = FALSE)]
dt[, temp_times := as.character(temp_times)]
dt[, cnt_total_time := fifelse(is.na(cnt_total_time), temp_times, cnt_total_time)]
dt[, temp_times := NULL]
dt[, cnt_hours := NULL]
dt[, cnt_mins := NULL]

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
dt[, (cols) := lapply(.SD, spss_date), .SDcols = cols ]

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

# Text data ----------------------------------------------------------


## Removing spaces ---------------------------------------------------------

dt[, part_social_group := gsub("  ", " ", part_social_group)]

# Behaviour and attitudes -------------------------------------------------
att_cols <- grep("part_att", names(dt), value = TRUE)
print(paste0("Attitude vars: ", length(att_cols)))

## Three types write a function for each and label them.
dt[, table(part_att_serious)]
dt[, table(part_att_eff_reduce_contacts)]
dt[, table(part_att_can_reduce_contacts)]

# Visiting places ---------------------------------------------------------
visit_cols <- grep("part_visit", names(dt), value = TRUE)
print(paste0("Visit vars: ", length(att_cols)))

## Need to change these to yes and no. 

dt[, table(part_visit_pub)]
dt[, table(part_visit_salon)]





# Locations ---------------------------------------------------------------

dt[, table(area_3_name)]
if(dt$country_code[1] == "UK") {
  dt <- dt[, regions := fcase(
    area_3_name == "Yorkshire and The Humber", "Yorkshire and The Humber",
    area_3_name == "Yorkshire and Humberside", "Yorkshire and The Humber",
    area_3_name == "Yorkshire and", "Yorkshire and The Humber",
    area_3_name == "East Anglia", "East of England",
    area_3_name == "East of England", "East of England",
    area_3_name == "East of Engla", "East of England",
    area_3_name == "Greater London", "Greater London",
    area_3_name == "Greater Londo", "Greater London",
    area_3_name == "North East", "North East",
    area_3_name == "North West", "North West",
    area_3_name == "South East", "South East",
    area_3_name == "South West", "South West",
    area_3_name == "West Midlands", "West Midlands",
    area_3_name == "East Midlands", "East Midlands",
    area_3_name == "Northern Ireland", "Northern Ireland",
    area_3_name == "Northern Irel", "Northern Ireland",
    
    area_3_name == "Scotland", "Scotland",
    area_3_name == "Wales", "Wales"
  )
  ]
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




qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))



# Numeric data ----------------------------------------------------------



# Age ---------------------------------------------------------------------

## Adults report on behalf of children. Therefore need to swap participant and child age



# Cleaning ----------------------------------------------------------------








    
  