## Name: dm07_clean_existing_vars.R
## Description: Run checks and process variables already present in the data.
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



# Label values ------------------------------------------------------------

## Gender
dt[, part_gender    := map_gender[part_gender]]
dt[, part_gender_nb := map_gender[part_gender_nb]]
dt[, cnt_gender := map_gender[cnt_gender]]
dt[, hhm_gender := map_gender[hhm_gender]]


# Identify household members ----------------------------------------------

dt[row_id ==0 | !is.na(hhm_age_group), hhm := "Yes"]

dt[hhm == "Yes" & country == "uk", table(panel, wave)]

dt[is.na(cnt_age) & is.na(hhm_age_group) & country == "uk" &
      (cnt_mass != "mass" | is.na(cnt_mass)) & row_id != 0, 
   .(country, part_id, cnt_age, hhm_age_group, 
     panel, wave, cnt_mass, cnt_home, cnt_school)][order(panel)]
   


dt[is.na(cnt_age) | row_id !=0, hhm := "Yes"]

# Participant's age ---------------------------------------------------------------------

## Put the min and max of the children's age's into a min and max ver.
## Then make participant's age numeric and have missing for kids.
dt[, part_age_int := as.numeric(part_age)]
dt[part_age == "Prefer not to answer", part_age := NA]

dt[, part_age_min := part_age_int]
dt[, part_age_max := part_age_int]
dt[part_age == "Under 1", part_age_min := 0]
dt[part_age == "Under 1", part_age_max := 1]

dt[is.na(part_age_min), part_age_min := as.numeric(str_replace_all(part_age, "-.*", ""))]
dt[is.na(part_age_max), part_age_max := as.numeric(str_replace_all(part_age, ".*-", ""))]
dt[is.na(part_age_min), part_age_min := as.numeric(str_replace_all(part_age, "\\+", ""))]
dt[is.na(part_age_max), part_age_max := as.numeric(str_replace_all(part_age, ".*\\+", "120"))]


# Clean children age groups -----------------------------------------------

## Acceptable child age groups
child_age_groups <- c("0-4", "5-11", "12-17")

## Make sample_type present in all questions
dt[, sample_type := first(sample_type), by = part_id]
dt[sample_type == "child" & part_age_max == 1, part_age_max := 4]
dt[sample_type == "child" & part_age_min > 0 & part_age_max <5, part_age_min := 0]
dt[sample_type == "child" & part_age_min > 0 & part_age_max <5, part_age_max := 4]
dt[sample_type == "child" & part_age_min > 4 & part_age_max <12, part_age_min := 5]
dt[sample_type == "child" & part_age_min > 4 & part_age_max <12, part_age_max := 11]
dt[sample_type == "child" & part_age_min > 11 & part_age_max <18, part_age_min := 12]
dt[sample_type == "child" & part_age_min > 11 & part_age_max <18, part_age_max := 17]

dt[sample_type == "child" & part_age_min > 17,  part_age_min := 0]
dt[sample_type == "child" & part_age_max > 17,  part_age_max := 17]

dt[!is.na(part_age_min), part_age_group := paste0(part_age_min, "-", part_age_max)]


dt[, part_age := part_age_int]
dt[, part_age_int := NULL]

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
dt[cnt_age == "Don’t know", cnt_age_min := 0]
dt[cnt_age == "Don’t know", cnt_age_max := 120]
dt[cnt_age == "Prefer not to answer", cnt_age_min := 0]
dt[cnt_age == "Prefer not to answer", cnt_age_max := 120]
dt[cnt_age == "Under 1", cnt_age_min := 0]
dt[cnt_age == "Under 1", cnt_age_max := 1]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_age_min := as.numeric(str_replace_all(cnt_age, "\\+", ""))]
dt[cnt_age %like% "^[0-9]+\\+$", cnt_age_max := 120]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_age_min := as.numeric(str_replace_all(cnt_age, "-[0-9]+", ""))]
dt[cnt_age %like% "^[0-9]+-[0-9]+$", cnt_age_max := as.numeric(str_replace_all(cnt_age, "[0-9]+-", ""))]

dt[!is.na(cnt_age_min), cnt_age_group := paste0(cnt_age_min, "-", cnt_age_max)]


dt[country == "uk" & !is.na(part_age_group), table(panel, wave)]
dt[country == "uk" & !is.na(cnt_age), table(cnt_age_max)]

## Looking at how many mass versus individual contacts


dt[country == "uk", table(country, panel, sample_type, useNA = "ifany")]
dt[cnt_mass == "mass" & country == "uk", .(row_id, country, panel, sample_type, cnt_mass)]

dt[country == "uk" & (!is.na(cnt_age) | hhm_contact_yn == "Yes"),table(panel, wave, sample_type)]
dt[country == "uk", table(cnt_mass, wave, panel, useNA = "ifany")]
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

dt[country == "uk" & !is.na(cnt_age_group),table(panel, wave)]

dt[, cnt_frequency := map_freq[cnt_frequency]]

contacts <- readRDS('../comix/data/clean_contacts.rds')
table(contacts$panel, contacts$wave)
dt[, table(cnt_frequency)]

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
   hh_type := "Lone_parent with dependent children"
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


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

