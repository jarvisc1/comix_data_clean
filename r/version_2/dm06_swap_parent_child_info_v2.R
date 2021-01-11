## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5_v2.qs
## Functions:
## Output file: combined_6_v2.qs

# 
# Children's data notes (panel C and D)
# 1. The chosen child's demographic data is stored in the household data with the 
#      child's row_id (1:19, general) (gender, hhm_age_group)
# 2. Reference to the chosen child's id is stored in child_hhm_select_raw
# 3. The parent's demographics are stored with row_id == 0 
#      (part_age, part_gender, part_gender_nb, part_social_group, part_occupation, part_income, etc)
# 4. Some child's information is stored in row_id == 0 (part_face_mask, part_school_class_size, etc)
# 4. The parent's contact with the chosen child data is stored in row_id == 999 
#      (hhm_contact, cnt_work, cnt_frequency, etc)


# Steps: (This order is necessary)
# 1. Identify chosen's child's id with a regex from child_hhm_select raw,
#    create <child_id> column
# 2. Identify parent contact row (row_id == 999)
# 3. Identify mixed data row (row_id == 0)
# 4. Fill in parent's demographic data FROM row_id == 0 TO row_id == 999
#    (example <part_age to )
# 5. Fill child's demographic data in TO row_id == 0 FROM the child_id row's
#    household info (example: use <hhm_age_group> FROM row_id 4 to
#    fill in the <hhm_age_group> TO row id 0)
# 6. Group parent's age (row_id == 999)
# 7. Remove row_id == child_id (data has been moved to row_id == 0)


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5_v2.qs")
output_name <- paste0("combined_6_v2.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

original_child_nrow <- nrow(dt)

## Panel C, D for UK are children
dt[, sample_type := "child"]

dt[, sample_type := first(sample_type), by = .(country, panel, wave, part_id)]

# STEP 1: Identify chosen child's id and selected child------------------------
hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]
dt[, child_id := first(child_id), by = .(country, panel, wave, part_id)]
dt[child_id == row_id, parent_child := "child"]

# STEP 2, 3, Identify mixed data and parent rows ------------------------------

dt[row_id == 0, mixed_data := TRUE]
dt[row_id == 999, parent_child := "parent"]

# Find empty columns in parent data
emptycols_na <- colSums(!is.na(dt[mixed_data == TRUE])) == nrow(dt[mixed_data == TRUE])
emptycols_na <- names(emptycols_na[emptycols_na])
grep("hhm_", emptycols_na, value = TRUE)


# Inlcude parent data in child's data
child_emptycols_na <- c("part_income", "part_social_group")
for(fill_col in child_emptycols_na) {
  dt[parent_child %in% c("child") | mixed_data == TRUE,
     (fill_col) := first(get(fill_col)),
     by = .(part_id, panel, wave, country)]
}

# Step 4 Fill in parent (part_id 999) household member data from participant data -----

parent_cols <-
   c("part_age", "part_employstatus",
     "part_gender",  "part_gender_nb",  "part_no_contacts",
     "part_occupation", "part_social_group",
     "hhm_covid_contact", "hhm_covid_test",
     "hhm_high_risk", "hhm_isolate", "hhm_isolate_atleast_one_day",
     "hhm_quarantine", "hhm_quarantine_one_day", "hhm_symp_ache",
     "hhm_symp_congestion", "hhm_symp_cough", "hhm_symp_dk", "hhm_symp_fever",
     "hhm_symp_no_answer", "hhm_symp_none", "hhm_symp_sob", "hhm_symp_sore_throat",
     "hhm_symp_tired"
   )

for(parent_col in parent_cols) {
   hhm_col <- gsub("part_", "hhm_", parent_col)
   dt[mixed_data == TRUE | parent_child == "parent",
      (hhm_col) := first(get(parent_col)),
      by = .(part_id, panel, wave, country)]
   
}

table(dt$parent_child, dt$part_social_group)
## STEP 5. Fill in child (row_id == child_id) part_data from hhm data
hhm_cols <- c("hhm_gender", "hhm_age_group")

for(hhm_col in hhm_cols) {
   part_col <- gsub("hhm_", "part_", hhm_col)
   dt[mixed_data == T | parent_child == "child", 
      (part_col) := last(get(hhm_col)), 
      by = .(part_id, panel, wave, country)]
}



# Step 6 Add adult age group--------------------------------------------------
dt[between(hhm_age, 18, 19) & parent_child == "parent", hhm_age_group := "18-19"]
dt[between(hhm_age, 20, 24) & parent_child == "parent", hhm_age_group := "20-24"]
dt[between(hhm_age, 25, 29) & parent_child == "parent", hhm_age_group := "25-29"]
dt[between(hhm_age, 30, 34) & parent_child == "parent", hhm_age_group := "30-34"]
dt[between(hhm_age, 35, 39) & parent_child == "parent", hhm_age_group := "35-39"]
dt[between(hhm_age, 40, 44) & parent_child == "parent", hhm_age_group := "40-44"]
dt[between(hhm_age, 45, 49) & parent_child == "parent", hhm_age_group := "45-49"]
dt[between(hhm_age, 50, 54) & parent_child == "parent", hhm_age_group := "50-54"]
dt[between(hhm_age, 55, 59) & parent_child == "parent", hhm_age_group := "55-59"]
dt[between(hhm_age, 60, 65) & parent_child == "parent", hhm_age_group := "60-64"]
dt[between(hhm_age, 65, 69) & parent_child == "parent", hhm_age_group := "65-69"]
dt[between(hhm_age, 70, 120) & parent_child == "parent", hhm_age_group := "70+"]


## STEP 7. Fill in original household size
dt[sample_type == "child", hh_size := first(hh_size),
   by = .(country, panel, part_id)]

## STEP 8. Remove now-reduntant child hhm row and assign mixed_data row (row_id == 0) to child 
dt <- dt[parent_child != "child" | is.na(parent_child)]

dt[mixed_data == TRUE, parent_child := "child"]

# For visual testing
table(dt$parent_child, dt$panel, useNA = "always")
table(dt[sample_type == "child"]$part_public_transport_bus, useNA = "always")
table(dt[parent_child == "child"]$part_age_group, dt[parent_child == "child"]$wave)
table(dt[mixed_data == T]$part_age_group, dt[mixed_data == T]$wave)
original_child_nrow  == nrow(dt[panel %in% c("C", "D")]) + nrow(dt[parent_child == "child"])

table(dt[row_id == 999]$hhm_gender, useNA = "always")
table(dt[row_id == 0]$part_gender, useNA = "always")
table(dt[parent_child == "parent"]$hhm_age_group, 
      dt[parent_child == "parent"]$wave)
table(dt[parent_child == "parent"]$hhm_symp_fever)
table(dt[parent_child == "parent"]$hhm_high_risk)
table(dt[parent_child == "child"]$part_face_mask,
      dt[parent_child == "child"]$panel, useNA = "always")
table(dt[parent_child == "parent"]$hhm_contact,
      dt[parent_child == "parent"]$panel, useNA = "always")
table(dt[parent_child == "parent"]$row_id)
table(dt[parent_child == "child"]$multiple_contacts_child_school,
      dt[parent_child == "child"]$wave, useNA = "always")


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))
