## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5_v5.qs
## Functions:
## Output file: combined_6_v5.qs

# 
# Children's data notes (panel E and F)
# 1. The chosen child's demographic data is stored in the household data with the 
#    child's row_id (hhm_gender, hhm_age_group)
# 2. Reference to the chosen child's id is stored in child_hhm_select_raw
# 3. The parent's demographics and contact with the chosen child data 
#    are stored with row_id == 0
#    (part_age, part_gender, part_gender_nb, part_social_group, part_occupation, part_income, etc)
# 4. Some child's information is stored in row_id == 0 (uk_region1, etc)



# Steps: (This order is necessary)
# 1. Identify children's EF data
# 2. Identify chosen's child's id with a regex from child_hhm_select raw,
#    create <child_id> column
# 3. Identify parent contact row (row_id == 0)
# 4. Fill child's demographic data in TO row_id == 0 FROM the child_id row's
#    household info (example: use data FROM row_id == 0 <uk_region1> and 
#    <part_occupation> to fill in the same cols TO row_id == 4)
# 5. Move relevant child hhm data to part data columns (age, gender)
# 6. Move relevant parent part data to hhm data columns (age, gender, etc)
# 7. Group parent's age (row_id == 999)
# 8. Assign parent's row_id to 999 and child's row_id to 0


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5_v5.qs")
output_name <- paste0("combined_6_v5.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 
print(paste(unique(dt$country), collapse = ", "))

# Standardize child age groups for Belgium

dt[, hhm_age_group_be := hhm_age_group]
dt[hhm_age_group == "5-6", hhm_age_group := "5-11"]
dt[hhm_age_group == "7-11", hhm_age_group := "5-11"]


# Step 1: Identify the adult and children samples -------------------------------------------------------------
map_sample_type <- c(
  "Sampletype=1 Main sample" = "adult",
  "Sampletype=2 Parent sample" = "child"
)
dt[,sample_type := map_sample_type[sample_type]]
table(dt$sample_type, dt$wave)

dt[, sample_type := first(sample_type), by = .(country, panel, wave, part_id)]
original_child_nrow <- nrow(dt)

#table(dt$sample_type, dt$row_id)
# Step 2: Identify chosen child's id and selected child------------------------
hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]
dt[, child_id := first(child_id), by = .(country, panel, wave, part_id)]
dt[child_id == row_id, parent_child := "child"]

# STEP 3. Identify mixed data and parent rows ------------------------------

# dt[sample_type == "child" & row_id == 0, mixed_data := T]
dt[sample_type == "child" & row_id == 0, parent_child := "parent"]
dt[sample_type == "child" & row_id == 0, mixed_data := TRUE]


# Step 4. ID and fill in relevant data from parent row to child row -----
child_emptycols_na <- colSums(is.na(dt[parent_child == "child"])) == nrow(dt[parent_child == "child"])
child_emptycols_na <- names(child_emptycols_na[child_emptycols_na])
parent_emptycols_na <- colSums(is.na(dt[parent_child == "parent"])) == nrow(dt[parent_child == "parent"])
parent_emptycols_na <- names(parent_emptycols_na[parent_emptycols_na])

child_emptycols_na <- setdiff(child_emptycols_na, parent_emptycols_na)
child_emptycols_na <- grep("gender|age|cnt_", child_emptycols_na, invert = TRUE, value = TRUE)

for(fill_col in child_emptycols_na) {
  dt[parent_child %in% c("parent", "child"),
     (fill_col) := first(get(fill_col)),
     by = .(part_id, panel, wave, country)]
}

# Step pre-5
dt[sample_type=="adult" & row_id == 0, part_elevated_risk := hhm_elevated_risk]
dt[sample_type=="adult" & row_id == 0, hhm_elevated_risk := NA]

# Step 5. Rename relevant child hhm data to part data columns ----
hhm_cols <- c("hhm_gender","hhm_gender", "hhm_age_group", "hhm_age_group_be", "hhm_elevated_risk")
for(hhm_col in hhm_cols) {
  part_col <- gsub("hhm_", "part_", hhm_col)
  dt[parent_child == "child",
     (part_col) := (get(hhm_col)),
     by = .(part_id, panel, wave, country)]
}

# Step pre-6
dt[parent_child=="child", hhm_elevated_risk := NA]

# Step 6. Move relevant parent part data to hhm data columns ----
part_cols <- c("part_gender", "part_age")
for(part_col in part_cols) {
  hhm_col <- gsub("part_", "hhm_", part_col)
  dt[parent_child %in% c("parent", "child") ,
     (hhm_col) := first(get(part_col)),
     by = .(part_id, panel, wave, country)]
  dt[parent_child == "child", (hhm_col) := NA]
  dt[parent_child == "parent", (part_col) := NA]
}

#table(dt[parent_child == "parent"]$hhm_gender)

# Step 7. Add adult age group--------------------------------------------------
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


## STEP 8. Remove now-reduntant child hhm row and assign mixed_data row (row_id == 0) to child 
dt[parent_child == "parent", row_id := 999]
dt[parent_child == "child", row_id := 0]

dt[parent_child == "child", hhm_contact := "No"]


# # For visual testing
# table(dt$parent_child, dt$wave, dt$panel, useNA = "always")
# table(dt[sample_type == "child"]$part_public_transport_bus, useNA = "always")
# table(dt[parent_child == "child"]$part_age_group, dt[parent_child == "child"]$wave)
# table(dt[parent_child == "child"]$part_age_group_be, dt[parent_child == "child"]$wave)
# 
# 
# table(dt[mixed_data == T]$part_age_group, dt[mixed_data == T]$wave)
# original_child_nrow  == nrow(dt[panel %in% c("B")])
# 
# table(dt[row_id == 999]$hhm_gender, useNA = "always")
# table(dt[row_id == 0]$part_gender, useNA = "always")
# table(dt[parent_child == "parent"]$hhm_age_group, 
#       dt[parent_child == "parent"]$wave, useNA = "always")
# table(dt[parent_child == "parent"]$hhm_symp_fever)
# table(dt[parent_child == "parent"]$hhm_contact,
#       dt[parent_child == "parent"]$panel, useNA = "always")
# table(dt[parent_child == "parent"]$row_id)
# # table(dt[parent_child == "child"]$multiple_contacts_child_school,
#       # dt[parent_child == "child"]$wave, useNA = "always")
# table(dt[]$part_age_group, 
#       dt[]$wave, useNA = "always")

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

