## Name: dm09_clean_other_vars.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs



# Packages ----------------------------------------------------------------
library(data.table)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_10.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_11.qs")
output_data <- file.path(dir_data_process, output_name)

## Save participant data
current_date <- Sys.Date()
output_parts <- paste0("part.qs")
output_parts_min <- paste0("part_min.qs")
output_parts_date <- paste(current_date, output_parts, sep = "_")
output_data_parts <- file.path("data/clean", output_parts)
output_data_parts_min <- file.path("data/clean", output_parts_min)
output_data_parts_date <- file.path("data/clean/archive", output_parts_date)

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

# Clean participants ------------------------------------------------------



## Removing spaces ---------------------------------------------------------

dt[, part_social_group := gsub("  ", " ", part_social_group)]

# Behaviour and attitudes -------------------------------------------------

## Formatting variables
att_eff_levels <- c("Very effective", "Fairly effective", "Not very effective",
                    "Not at all effective", "Don’t know")
att_levels <- c("Strongly agree", "Tend to agree", "Neither agree nor disagree",
                "Tend to disagree", "Strongly disagree", "Don’t know")
att_can_levels <- c("Very confident", "Fairly confident", "Not very confident",
                    "Not at all confident", "Don’t know")

## Attitude of effectiveness
part[, part_att_eff_reduce_contacts := factor(part_att_eff_reduce_contacts, levels = att_eff_levels)]
part[, part_att_eff_stay_home7_mild := factor(part_att_eff_stay_home7_mild, levels = att_eff_levels)]
part[, part_att_eff_stay_home7_severe := factor(part_att_eff_stay_home7_severe, levels = att_eff_levels)]
part[, part_att_eff_crowd_places := factor(part_att_eff_crowd_places, levels = att_eff_levels)]
part[, part_att_eff_stay_home14_mild_not_you := factor(part_att_eff_stay_home14_mild_not_you, levels = att_eff_levels)]
part[, part_att_eff_stay_home14_severe_not_you := factor(part_att_eff_stay_home14_severe_not_you, levels = att_eff_levels)]
part[, part_att_eff_ban_int_travel := factor(part_att_eff_ban_int_travel, levels = att_eff_levels)]
part[, part_att_eff_ban_dom_travel := factor(part_att_eff_ban_dom_travel, levels = att_eff_levels)]
part[, part_att_eff_school_closures := factor(part_att_eff_school_closures, levels = att_eff_levels)]
part[, part_att_eff_leisure_closures := factor(part_att_eff_leisure_closures, levels = att_eff_levels)]
part[, part_att_eff_ban_public_transport := factor(part_att_eff_ban_public_transport, levels = att_eff_levels)]

## Ability to do these actions
part[, part_att_can_reduce_contacts := factor(part_att_can_reduce_contacts, levels = att_can_levels)]
part[, part_att_can_stay_home7_mild := factor(part_att_can_stay_home7_mild, levels = att_can_levels)]
part[, part_att_can_stay_home7_severe := factor(part_att_can_stay_home7_severe, levels = att_can_levels)]
part[, part_att_can_crowd_places := factor(part_att_can_crowd_places, levels = att_can_levels)]
part[, part_att_can_stay_home14_mild_not_you := factor(part_att_can_stay_home14_mild_not_you, levels = att_can_levels)]
part[, part_att_can_stay_home14_severe_not_you := factor(part_att_can_stay_home14_severe_not_you, levels = att_can_levels)]
part[, part_att_can_not_use_public_transport := factor(part_att_can_not_use_public_transport, levels = att_can_levels)]
## Consequences for doing them
part[, part_att_expect_work := factor(part_att_expect_work, levels = att_levels)]
part[, part_att_cant_work_paid := factor(part_att_cant_work_paid, levels = att_levels)]
part[, part_att_isolate_has_child_care := factor(part_att_isolate_has_child_care, levels = att_levels)]
part[, part_att_isolate_problems := factor(part_att_isolate_problems, levels = att_levels)]
part[, part_att_isolate_enough_food := factor(part_att_isolate_enough_food, levels = att_levels)]
part[, part_att_expect_work_yn := factor(part_att_expect_work_yn, levels = c("Yes", "No"))]
part[, part_att_cant_work_paid_yn := factor(part_att_cant_work_paid_yn, levels = c("Yes", "No"))]
part[, part_att_isolate_has_child_care_yn := factor(part_att_isolate_has_child_care_yn, levels = c("Yes", "No"))]
part[, part_att_isolate_problems_yn := factor(part_att_isolate_problems_yn, levels = c("Yes", "No"))]
part[, part_att_isolate_enough_food_yn := factor(part_att_isolate_enough_food_yn, levels = c("Yes", "No"))]


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
                "country",
                "panel", 
                "wave",
                "survey_round",
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



