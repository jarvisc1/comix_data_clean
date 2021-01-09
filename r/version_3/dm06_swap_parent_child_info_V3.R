## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5.qs
## Functions:
## Output file: combined_6.qs

# 
# Children's data notes (panel E and F)
# 1. The chosen child's demographic data is stored in the household data with the 
#    child's row_id (hhm_gender, hhm_age_group)
# 2. Reference to the chosen child's id is stored in child_hhm_select_raw
# 3. The parent's demographics and contact with the chosen child data 
#    are stored with row_id == 999 
#    (part_age, part_gender, part_gender_nb, part_social_group, part_occupation, part_income, etc)
# 4. Some child's information is stored in row_id == 0 (uk_region1, etc)



# Steps: (This order is necessary)
# 1. Identify children's EF data
# 2. Identify chosen's child's id with a regex from child_hhm_select raw,
#    create <child_id> column
# 3. Identify parent contact row (row_id == 999)
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
t <- Sys.time()

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5.qs")
output_name <- paste0("combined_6.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

## Panel C, D for UK are children



# STEP 1: Identify the adult and children samples -------------------------------------------------------------
map_sample_type <- c(
  "Sampletype=1 Main sample" = "adult",
  "Sampletype=2 Parent sample" = "child_EF"
)
dt[country == "uk" & panel %in% c("E", "F"), sample_type := map_sample_type[sample_type]]
table(dt$sample_type)
dt[country == "uk" & panel %in% c("E", "F"), sample_type := first(sample_type), by = .(country, panel, wave, part_id)]
original_child_nrow <- nrow(dt[panel %in% c("E", "F")])

table(dt$sample_type, dt$row_id)
# STEP 2: Identify chosen child's id and selected child------------------------
hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]
dt[, child_id := first(child_id), by = .(country, panel, wave, part_id)]
dt[child_id == row_id, parent_child := "child_EF"]

# STEP 3. Identify mixed data and parent rows ------------------------------

# dt[sample_type == "child_EF" & row_id == 0, mixed_data := T]
dt[sample_type == "child_EF" & row_id == 0, parent_child := "parent"]
dt[sample_type == "child_EF" & row_id == 0, mixed_data := TRUE]


# STEP 4. ID and fill in relevant data from parent row to child row
child_emptycols_na <- colSums(is.na(dt[parent_child == "child_EF"])) == nrow(dt[parent_child == "child_EF"])
child_emptycols_na <- names(child_emptycols_na[child_emptycols_na])
parent_emptycols_na <- colSums(
  is.na(dt[panel %in% c("E", "F") & parent_child == "parent"])) == 
  nrow(dt[panel %in% c("E", "F") & parent_child == "parent"])
parent_emptycols_na <- names(parent_emptycols_na[parent_emptycols_na])

child_emptycols_na <- setdiff(child_emptycols_na, parent_emptycols_na)
child_emptycols_na <- grep("gender|age|cnt_", child_emptycols_na, invert = T, value = T)

for(fill_col in child_emptycols_na) {
  dt[panel %in% c("E", "F") & parent_child %in% c("parent", "child_EF"),
     (fill_col) := first(get(fill_col)),
     by = .(part_id, panel, wave, country)]
}

# STEP 5. Move relevant child hhm data to part data columns
hhm_cols <- c("hhm_gender","hhm_gender", "hhm_age_group")
for(hhm_col in hhm_cols) {
  part_col <- gsub("hhm_", "part_", hhm_col)
  dt[parent_child == "child_EF",
     (part_col) := (get(hhm_col)),
     by = .(part_id, panel, wave, country)]
}

# Step 6. Move relevant parent part data to hhm data columns
part_cols <- c("part_gender","part_gender", "part_age")
for(part_col in part_cols) {
  hhm_col <- gsub("part_", "hhm_", part_col)
  dt[panel %in% c("E", "F") & parent_child %in% c("parent", "child_EF"),
     (hhm_col) := first(get(part_col)),
     by = .(part_id, panel, wave, country)]
  dt[parent_child == "child_EF", (hhm_col) := NA]
}
table(dt[panel %in% c("E", "F") & parent_child == "parent"]$hhm_gender)

## STEP 7. Add adult age group
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 18, 19), "18-19", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 20, 24), "20-24", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 25, 29), "25-29", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 30, 34), "30-34", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 35, 39), "35-39", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 40, 44), "40-44", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 45, 49), "45-49", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 50, 54), "50-54", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 55, 59), "55-59", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 60, 64), "60-64", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 65, 69), "65-69", hhm_age_group)]
dt[panel %in% c("E", "F") & parent_child == "parent", hhm_age_group := 
     ifelse(between(hhm_age, 70, 120), "70+", hhm_age_group)]


## STEP 8. Remove now-reduntant child hhm row and assign mixed_data row (row_id == 0) to child 
dt[panel %in% c("E", "F") & parent_child == "parent", row_id := 999]
dt[panel %in% c("E", "F") & parent_child == "child_EF", row_id := 0]



message(Sys.time() - t)

# For visual testing
table(dt$parent_child, dt$panel, useNA = "always")
table(dt[sample_type == "child_EF"]$part_public_transport_bus, useNA = "always")
table(dt[parent_child == "child_EF"]$part_age_group, dt[parent_child == "child_EF"]$wave)
table(dt[mixed_data == T]$part_age_group, dt[mixed_data == T]$wave)
original_child_nrow  == nrow(dt[panel %in% c("E", "F")])

table(dt[panel %in% c("E", "F") & row_id == 999]$hhm_gender, useNA = "always")
table(dt[panel %in% c("E", "F") & row_id == 0]$part_gender, useNA = "always")
table(dt[panel %in% c("E", "F") & parent_child == "parent"]$hhm_age_group, 
      dt[panel %in% c("E", "F") & parent_child == "parent"]$wave)
table(dt[panel %in% c("E", "F") & parent_child == "parent"]$hhm_symp_fever)
table(dt[panel %in% c("E", "F") & parent_child == "parent"]$hhm_contact,
      dt[panel %in% c("E", "F") & parent_child == "parent"]$panel, useNA = "always")
table(dt[panel %in% c("E", "F") & parent_child == "parent"]$row_id)
table(dt[parent_child == "child_EF"]$multiple_contacts_child_school,
      dt[parent_child == "child_EF"]$wave, useNA = "always")


# Save data ---------------------------------------------------------------
dt[parent_child == "child_EF", parent_child := "child"]
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

