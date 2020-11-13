## Name: dm07_clean_contact_vars.R
## Description: Clean the variables relating to the contact data.
## Input file: combined_7.qs
## Functions:
## Output file: combined_8.qs


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


# Empty contacts ----------------------------------------------------------
dt <- dt[contact != "0" | is.na(contact)]

## There are excess _i variables from IPSOS which are useful
set(dt, j = grep(".*_i$", names(dt), value = TRUE), value = NULL)

setkey(dt, country, panel, wave,part_id)
# Map objects for labels --------------------------------------------------


### Kerry these could all go in a different script to be maintained elsewhere?
### Then we would add a section on the readme about how to add label maps
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
   "0" = "0", 
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

YesNoNA_Ind = function(x)
{
   ifelse(x == "Yes", 1,
          ifelse(x == "No", 0, NA))
}

# Label values ------------------------------------------------------------

## Gender
dt[, part_gender    := map_gender[part_gender]]
dt[, part_gender_nb := map_gender[part_gender_nb]]
dt[, cnt_gender := map_gender[cnt_gender]]
dt[, hhm_gender := map_gender[hhm_gender]]

# Contact dates -----------------------------------------------------------
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

# Identify household members ----------------------------------------------

dt[row_id ==0 | !is.na(hhm_age_group), hhm := "Yes"]

## Identify contacts

dt[(!is.na(cnt_age) | hhm_contact_yn == "Yes"), cnt := "Yes"]

# Physical contacts -------------------------------------------------------

## Variable changed through panels

dt[grepl("Physical contact \\(any sort", phys), phys := "Yes" ]
dt[grepl("Non-physical contact", phys), phys := "No"]
dt[grepl("Prefer not to answer", phys), phys := NA_character_]

dt[is.na(cnt_phys), cnt_phys := phys]

## Mass contact are treated as non-physical
dt[cnt_mass == "mass", cnt_phys := "No"]
dt[, phys := NULL]

# Participant's age ---------------------------------------------------------------------

## Put the min and max of the children's age's into a min and max ver.
## Then make participant's age numeric and have missing for kids.
dt[, part_age_int := as.numeric(part_age)]
dt[part_age == "Prefer not to answer", part_age := NA]

dt[, part_est_age_min := part_age_int]
dt[, part_est_age_max := part_age_int]
dt[part_age == "Under 1", part_est_age_min := 0]
dt[part_age == "Under 1", part_est_age_max := 1]

dt[is.na(part_est_age_min), part_est_age_min := as.numeric(str_replace_all(part_age, "-.*", ""))]
dt[is.na(part_est_age_max), part_est_age_max := as.numeric(str_replace_all(part_age, ".*-", ""))]
dt[is.na(part_est_age_min), part_est_age_min := as.numeric(str_replace_all(part_age, "\\+", ""))]
dt[is.na(part_est_age_max), part_est_age_max := as.numeric(str_replace_all(part_age, ".*\\+", "120"))]

# Clean children age groups -----------------------------------------------

## Acceptable child age groups
child_age_groups <- c("0-4", "5-11", "12-17")

## Make sample_type present in all questions
dt[, sample_type := first(sample_type), by = part_id]
dt[sample_type == "child" & part_est_age_max == 1,                        part_est_age_max := 4]
dt[sample_type == "child" & part_est_age_min > 0 &  part_est_age_max <5,  part_est_age_min := 0]
dt[sample_type == "child" & part_est_age_min > 0 &  part_est_age_max <5,  part_est_age_max := 4]
dt[sample_type == "child" & part_est_age_min > 4 &  part_est_age_max <12, part_est_age_min := 5]
dt[sample_type == "child" & part_est_age_min > 4 &  part_est_age_max <12, part_est_age_max := 11]
dt[sample_type == "child" & part_est_age_min > 11 & part_est_age_max <18, part_est_age_min := 12]
dt[sample_type == "child" & part_est_age_min > 11 & part_est_age_max <18, part_est_age_max := 17]

dt[sample_type == "child" & part_est_age_min > 17,  part_est_age_min := NA_real_]
dt[sample_type == "child" & part_est_age_max > 17,  part_est_age_max := NA_real_]

## Cut up the age groups into categories
dt[between(part_est_age_min,  0, 4)   , age_min :=  0 ]
dt[between(part_est_age_min,  5,11)   , age_min :=  5 ]
dt[between(part_est_age_min,  12,17)  , age_min :=  12]
dt[between(part_est_age_min,  18,29)  , age_min :=  18]
dt[between(part_est_age_min,  30,39)  , age_min :=  30]
dt[between(part_est_age_min,  40,49)  , age_min :=  40]
dt[between(part_est_age_min,  50,59)  , age_min :=  50]
dt[between(part_est_age_min,  60,69)  , age_min :=  60]
dt[between(part_est_age_min,  70,120) , age_min :=  70]
dt[between(part_est_age_max,  0, 4)   , age_max :=  4 ]
dt[between(part_est_age_max,  5,11)   , age_max :=  11 ]
dt[between(part_est_age_max,  12,17)  , age_max :=  17]
dt[between(part_est_age_max,  18,29)  , age_max :=  29]
dt[between(part_est_age_max,  30,39)  , age_max :=  39]
dt[between(part_est_age_max,  40,49)  , age_max :=  49]
dt[between(part_est_age_max,  50,59)  , age_max :=  59]
dt[between(part_est_age_max,  60,69)  , age_max :=  69]
dt[between(part_est_age_max,  70,120) , age_max :=  120]

dt[!is.na(age_min), part_age_group := paste0(age_min, "-", age_max)]

dt[, part_age := part_age_int]
dt[, part_age_int := NULL]
dt[, age_min := NULL]
dt[, age_max := NULL]

# Contacts ----------------------------------------------------------------

# Remove non contacts -----------------------------------------------------

dt[, contact := map_contacts_error[contact]]
dt[is.na(contact), contact := map_contacts_error[pcontact]]
dt <- dt[!contact %in% c("sus multi", "sus non-contact", "poten hhm")]
dt[, contact := NULL]

# Contact's age -----------------------------------------------------------

# Fill in contact age with hhm age if a contact
dt[hhm_contact_yn == "Yes", cnt_age := hhm_age_group]
dt[hhm_contact_yn == "Yes", cnt_gender := hhm_gender]

## Remove the repeat contact's that are present in the ages.
dt[, remove_row := str_replace_all(cnt_age, ".*me.*|.*person.*|.*This.*","not_real")]

## Remove no contact ages such as "this is me"
dt <- dt[remove_row != "not_real" | is.na(cnt_age)]

# Create min and max age --------------------------------------------------
dt[, cnt_est_age_min := as.numeric(cnt_age)]
dt[, cnt_est_age_max := as.numeric(cnt_age)]
dt[cnt_age == "Don’t know", cnt_est_age_min := 0]
dt[cnt_age == "Don’t know", cnt_est_age_max := 120]
dt[cnt_age == "Prefer not to answer", cnt_est_age_min := 0]
dt[cnt_age == "Prefer not to answer", cnt_est_age_max := 120]
dt[cnt_age == "Under 1", cnt_est_age_min := 0]
dt[cnt_age == "Under 1", cnt_est_age_max := 1]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_est_age_min := as.numeric(str_replace_all(cnt_age, "\\+", ""))]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_est_age_max := 120]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_est_age_min := as.numeric(str_replace_all(cnt_age, "-[0-9]+", ""))]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_est_age_max := as.numeric(str_replace_all(cnt_age, "[0-9]+-", ""))]

dt[between(cnt_est_age_min,  0, 4)   , age_min :=  0 ]
dt[between(cnt_est_age_min,  5,11)   , age_min :=  5 ]
dt[between(cnt_est_age_min,  12,17)  , age_min :=  12]
dt[between(cnt_est_age_min,  18,29)  , age_min :=  18]
dt[between(cnt_est_age_min,  30,39)  , age_min :=  30]
dt[between(cnt_est_age_min,  40,49)  , age_min :=  40]
dt[between(cnt_est_age_min,  50,59)  , age_min :=  50]
dt[between(cnt_est_age_min,  60,69)  , age_min :=  60]
dt[between(cnt_est_age_min,  70,120) , age_min :=  70]
dt[between(cnt_est_age_max,  0, 4)   , age_max :=  4 ]
dt[between(cnt_est_age_max,  5,11)   , age_max :=  11 ]
dt[between(cnt_est_age_max,  12,17)  , age_max :=  17]
dt[between(cnt_est_age_max,  18,29)  , age_max :=  29]
dt[between(cnt_est_age_max,  30,39)  , age_max :=  39]
dt[between(cnt_est_age_max,  40,49)  , age_max :=  49]
dt[between(cnt_est_age_max,  50,59)  , age_max :=  59]
dt[between(cnt_est_age_max,  60,69)  , age_max :=  69]
dt[between(cnt_est_age_max,  70,120) , age_max :=  120]

dt[!is.na(age_min), cnt_age_group := paste0(age_min, "-", age_max)]
dt[,age_min := NULL]
dt[,age_max := NULL]

# Contact time ------------------------------------------------------------

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

# Contact relations --------------------------------------------------------

dt[, cnt_type := map_type[cnt_type]]
dt[hhm_contact_yn == "Yes", cnt_type := "household"]

dt[, cnt_frequency := map_freq[cnt_frequency]]

# Household - Kerry double check ------------------------------------------------------

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

## Removing spaces ---------------------------------------------------------

dt[, part_social_group := gsub("  ", " ", part_social_group)]

# Numeric data ----------------------------------------------------------

dt[, cnt_home := YesNoNA_Ind(cnt_home)]
dt[, cnt_work := YesNoNA_Ind(cnt_work)]
dt[, cnt_school := YesNoNA_Ind(cnt_school)]
dt[, cnt_outside_other := YesNoNA_Ind(cnt_outside_other)]
dt[, cnt_other_house := YesNoNA_Ind(cnt_other_house)]
dt[, cnt_health_facility := YesNoNA_Ind(cnt_health_facility)]
dt[, cnt_public_transport := YesNoNA_Ind(cnt_public_transport)]
dt[, cnt_salon := YesNoNA_Ind(cnt_salon)]
dt[, cnt_shop := YesNoNA_Ind(cnt_shop)]
dt[, cnt_sport := YesNoNA_Ind(cnt_sport)]
dt[, cnt_supermarket := YesNoNA_Ind(cnt_supermarket)]
dt[, cnt_worship := YesNoNA_Ind(cnt_worship)]
dt[, cnt_leisure := YesNoNA_Ind(cnt_leisure)]
dt[, cnt_public_market := YesNoNA_Ind(cnt_public_market)]
dt[, cnt_otheryn := YesNoNA_Ind(cnt_otheryn)]
dt[, cnt_inside := YesNoNA_Ind(cnt_inside)]
dt[, cnt_outside := YesNoNA_Ind(cnt_outside)]
dt[, cnt_other_text := YesNoNA_Ind(cnt_other_text)]

dt[, cnt_prec_none := YesNoNA_Ind(cnt_prec_none)]
dt[, cnt_prec_dk := YesNoNA_Ind(cnt_prec_dk)]
dt[, cnt_prec_2m_plus := YesNoNA_Ind(cnt_prec_2m_plus)]
dt[, cnt_prec_1m_plus := YesNoNA_Ind(cnt_prec_1m_plus)]
dt[, cnt_prec_within_1m := YesNoNA_Ind(cnt_prec_within_1m)]
dt[, cnt_prec_mask := YesNoNA_Ind(cnt_prec_mask)]
dt[, cnt_prec_wash_before := YesNoNA_Ind(cnt_prec_wash_before)]
dt[, cnt_prec_wash_after := YesNoNA_Ind(cnt_prec_wash_after)]
dt[, cnt_prec_prefer_not_to_say := YesNoNA_Ind(cnt_prec_prefer_not_to_say)]

dt[is.na(cnt_prec), cnt_prec := fifelse(cnt_prec_none == 0, "Yes", "No")]
dt[, cnt_prec_yn := cnt_prec]
dt[, cnt_prec := YesNoNA_Ind(cnt_prec_yn)]

# Participants ------------------------------------------------------------
part_cols <- grep("part", names(dt), value = TRUE)
print(paste0("Participant vars: ", length(part_cols)))

# Household members -------------------------------------------------------
hh_cols <- grep("hh", names(dt), value = TRUE)
print(paste0("Household vars: ", length(hh_cols)))


# Locations ---------------------------------------------------------------
loc_cols <- grep("area|region", names(dt), value = TRUE)
print(paste0("Location vars: ", length(loc_cols)))


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

