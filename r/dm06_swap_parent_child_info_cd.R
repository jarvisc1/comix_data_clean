## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5.qs
## Functions:
## Output file: combined_6.qs

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
# 3. Identify identify mixed data row (row_id == 0)
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
t <- Sys.time()

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5.qs")
output_name <- paste0("combined_6.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

dt <- dt[panel %in% c("C", "D")]
original_nrow <- nrow(dt)

## Panel C, D for UK are children
dt[ country == "uk" & panel %in% c("C", "D"), sample_type := "child"]

dt[, sample_type := first(sample_type), by = .(country, panel, wave, part_id)]

# STEP 1: Identify chosen child's id and selected child------------------------
hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]
dt[, child_id := first(child_id), by = .(country, panel, wave, part_id)]
dt[child_id == row_id, parent_child := "child"]

# STEP 2, 3, Identify mixed data and parent rows ------------------------------

dt[sample_type == "child" & row_id == 0, mixed_data := T]
dt[sample_type == "child" & row_id == 999, parent_child := "parent"]

emptycols_na <- colSums(!is.na(dt[mixed_data == T])) == nrow(dt[mixed_data == T])
emptycols_na <- names(emptycols_na[emptycols_na])
grep("hhm_", emptycols_na, value = T)


# STEP 4. Fill in parent (part_id 999) household member data from participant data
# (some of these cols are only in E & Fm commented out)
parent_cols <- 
   c("part_age", "part_education", "part_educationplace_status", "part_employstatus", 
     "part_gender",  "part_gender_nb",  "part_no_contacts", 
     "part_occupation", "part_social_group",
     ## only in E/F
     # "part_ethnicity", "part_ethnicity2", "part_furloughed", "part_antibody_test", 
     # "part_covid_test_past", "part_handsanit3h", "part_handwash3h", "part_high_risk_v2",
     # "part_med_risk_v2","part_pregnant", "part_social_group1", "part_social_group2", 
     # "part_ukitv", "part_workplace_status",
     ## potentially only in C/D
     "hhm_covid_contact", "hhm_covid_test", 
     "hhm_high_risk", "hhm_isolate", "hhm_isolate_atleast_one_day", 
     "hhm_quarantine", "hhm_quarantine_one_day", "hhm_symp_ache", 
     "hhm_symp_congestion", "hhm_symp_cough", "hhm_symp_dk", "hhm_symp_fever", 
     "hhm_symp_no_answer", "hhm_symp_none", "hhm_symp_sob", "hhm_symp_sore_throat", 
     "hhm_symp_tired"
     )

for(parent_col in parent_cols) {
   hhm_col <- gsub("part_", "hhm_", parent_col)
   dt[mixed_data == T | parent_child == "parent",
      (hhm_col) := first(get(parent_col)),
      by = .(part_id, panel, wave, country)]

}


## STEP 5. Fill in child (row_id == child_id) part_data from hhm data
hhm_cols <- c("hhm_gender", "hhm_age_group")

for(hhm_col in hhm_cols) {
   part_col <- gsub("hhm_", "part_", hhm_col)
   dt[mixed_data == T | parent_child == "child", 
      (part_col) := last(get(hhm_col)), 
       by = .(part_id, panel, wave, country)]
}

## STEP 6. Add adult age group
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 18, 19), "18-19", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 20, 24), "20-24", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 25, 29), "25-29", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 30, 34), "30-34", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 35, 39), "35-39", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 40, 44), "40-44", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 45, 49), "45-49", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 50, 54), "50-54", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 55, 59), "55-59", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 60, 64), "60-64", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 65, 69), "65-69", hhm_age_group)]
dt[parent_child == "parent", hhm_age_group := 
      ifelse(between(hhm_age, 70, 120), "70+", hhm_age_group)]


## STEP 7. Fill in original household size
dt[sample_type == "child", hh_size := first(hh_size),
   by = .(country, panel, part_id)]

## STEP 8. Remove now-reduntant child hhm row and assign mixed_data row (row_id == 0) to child 
dt <- dt[parent_child != "child" | is.na(parent_child)]

dt[mixed_data == TRUE, parent_child := "child"]


message(Sys.time() - t)
# # should be the same
table(dt$parent_child, dt$panel, useNA = "always")
table(dt[sample_type == "child"]$part_public_transport_bus, useNA = "always")
table(dt[parent_child == "child"]$part_age_group, dt[parent_child == "child"]$wave)
table(dt[mixed_data == T]$part_age_group, dt[mixed_data == T]$wave)
original_nrow == nrow(dt) + nrow(dt[parent_child == "child"])

table(dt[row_id == 999]$hhm_gender, useNA = "always")
table(dt[row_id == 0]$part_gender, useNA = "always")
table(dt[parent_child == "parent"]$hhm_age_group, dt[parent_child == "parent"]$wave)
table(dt[parent_child == "parent"]$hhm_symp_fever)
# table(dt[parent_child == "parent"]$hhm_high_risk)
# table(dt[parent_child == "child"]$part_face_mask, 
#       dt[parent_child == "child"]$panel, useNA = "always")
# table(dt[parent_child == "child"]$row_id)
# table(dt[parent_child == "parent"]$cnt_work,
#       dt[parent_child == "parent"]$panel, useNA = "always")
# table(dt[parent_child == "parent"]$row_id)
# table(dt[row_id == 0]$multiple_contacts_adult_school, 
#       dt[row_id == 0]$panel, useNA = "always")
# # 
# dt[part_id == 30001 & wave == 1 & row_id %in% c(0,999) & !(parent_child == "parent" & is.na(hhm_contact)),
#    list(part_id, panel, wave, row_id, parent_child, mixed_data, cnt_work, cnt_frequency, hhm_contact)]
# dt[part_id == 50002 & wave == 1 & row_id %in% c(0,999),
#    list(part_id, panel, wave, row_id, parent_child, mixed_data, hhm_gender, part_gender)]
# ## IMPORTANT

# table(dt[parent_child == "parent"]$hhm_contact, useNA = "always")
# duplicate?

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))








    
  