## Name: dm09_clean_household_v4.R
## Description: Clean variables related to household members.
## Input file: combined_9_v4.qs
## Functions:
## Output file: combined_10_v4.qs, households_v4



# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate, warn.conflicts = FALSE)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_9_v4.qs")
input_data <-  file.path(dir_data_process, input_name)
output_name <- paste0("combined_10_v4.qs")
output_hhms <- paste0("households_v4.qs")

## Save household data.
current_date <- Sys.Date()
output_hhms_date <- paste(current_date, output_hhms, sep = "_")
output_data <- file.path(dir_data_process, output_name)
output_data_hhms <- file.path("data/clean", output_hhms)
output_data_hhms_date <- file.path("data/clean/archive", output_hhms_date)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 
print(paste(unique(dt$country), collapse = ","))

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
dt[hh_type_partner == "No" &   
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


##Live alone
dt[hh_type_alone == "Yes", hh_type := "Live alone"]


##Copy value to different rows for each participant
dt[, hh_type := first(hh_type, na.rm = TRUE), 
   by = .(country, panel, wave, part_id)]

dt[is.na(hh_type), hh_type := "Other"]

hh_type_names <- grep("hh_type", names(dt), value = TRUE)
hh_type_names <- hh_type_names[hh_type_names != "hh_type"]

set(dt, j = hh_type_names, value = NULL)


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
dt[between(hh_size_int,6,13), hh_size_group := "6+",]

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



# Symptoms ----------------------------------------------------------------

dt[, hhm_symp_congestion := YesNoNA_Ind(hhm_symp_congestion)]
dt[, hhm_symp_cough := YesNoNA_Ind(hhm_symp_cough)]
dt[, hhm_symp_diarrhoea := YesNoNA_Ind(hhm_symp_diarrhoea)]
dt[, hhm_symp_dk := YesNoNA_Ind(hhm_symp_dk)]
dt[, hhm_symp_fever := YesNoNA_Ind(hhm_symp_fever)]
dt[, hhm_symp_fatigue := YesNoNA_Ind(hhm_symp_fatigue)]
dt[, hhm_symp_bodyaches := YesNoNA_Ind(hhm_symp_bodyaches)]
dt[, hhm_symp_headache := YesNoNA_Ind(hhm_symp_headache)]
dt[, hhm_symp_loss_senses := YesNoNA_Ind(hhm_symp_loss_senses)]
dt[, hhm_symp_nausea := YesNoNA_Ind(hhm_symp_nausea)]
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
             "survey_round",
             "weekday",
             "part_id",
             "part_uid",
             "part_wave_uid",
             "hhld_wave_uid",
             "contact_flag",
             "part_flag",
             "contact")
hhm_vars <- c(id_vars, hhm_names)
hhm_vars <- unique(hhm_vars)
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
  emptycols_na <- grep("area", emptycols_na, value = TRUE, inv = TRUE) #keep all area-related variables
  set(dt, j = emptycols_na, value = NULL)
}  

## Remove misc columns
remove <- c("hhcompconfirm", "hhcompremove", 
            "hhcompadd_scale_1", "child_hhm_select_raw_2", "")
hhms <- hhms[, (remove) := NULL]

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
