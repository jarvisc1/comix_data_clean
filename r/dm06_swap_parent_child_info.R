## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5.qs
## Functions:
## Output file: combined_6.qs


# Packages ----------------------------------------------------------------
library(data.table)
library(lubridate)
library(stringr)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_5.qs")
output_name <- paste0("combined_6.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Map objects for labels --------------------------------------------------


map_sample_type <- c(
  "Sampletype=1 Main sample" = "adult",
  "Sampletype=2 Parent sample" = "child"
)

# Row ids ----------------------------------------------------

## There are issues with the household ID in different versions of the dataset. 
   
# ## For Pan
# 
# # Re-calculate the hhm added by participants in the children's surveys to assign
# # hhm_ids to over 1000  (new household members are originally assigned variables
# # of 150 - 156) to group with the adult participant which is recorded as 999
# dt[panel %in% LETTERS[1:4], 
#     table_row :=
#       ifelse(row_id >= 150 & row_id <= 160, row_id - 150 + 1000, row_id)]
# 
# # Handles hhm who are added week to week (the row ids change week to week),
# # assigns value of over 999, original hhm are under 20
# # non-hhm contacts start at 20, to remain consistent with past data structure
# dt[panel %in% LETTERS[5:6] & row_id > 19 & row_id < 900,    
#    row_id := row_id + 999]
# dt[panel %in% LETTERS[1:4] & row_id >= 900 & row_id < 999 , 
#    row_id := row_id - 880]



# Identify the adult and children samples -------------------------------------------------------------

## clean sample types text
dt[, sample_type := map_sample_type[sample_type]]
## Panel A for BE, NL, and NO are all Adults
dt[ country %in% c("be", "nl", "no") & panel == "A", sample_type := "adult"]
dt[ country == "uk" & panel %in% c("A", "B"), sample_type := "adult"]
## Panel C, D for UK are children
dt[ country == "uk" & panel %in% c("C", "D"), sample_type := "child"]


# Fill in contact's age -----------------------------------------------------------

## If they're a household contact then their age is in hhm_age_group
dt[hhm_contact_yn == "Yes", cnt_age := hhm_age_group]
dt[hhm_contact_yn == "Yes", cnt_gender := hhm_gender]

## If they're a parent then their row id is 999 and info is in the part_age
# Put in their age and gender if they're a contact
dt[row_id == 999 & hhm_contact_yn == "Yes", cnt_age := part_age ]
dt[row_id == 999 & hhm_contact_yn == "Yes", cnt_gender := part_gender]
# Put in their age and gender as a household member
dt[row_id == 999, hhm_age_group := part_age]
dt[row_id == 999, hhm_gender := part_gender]
## Remove their values from parent samples
dt[sample_type == "child", part_age := NA]
dt[sample_type == "child", part_gender := NA]
dt[row_id == 999, part_gender := NA]


# Identify child -------------------------------------------------------

hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]

# Put in age for children ---------------------------------------------------------------------
dt[row_id == child_id, part_age := hhm_age_group]
dt[row_id == child_id, part_gender := hhm_gender]

## Reorder so non-missing age is at the top
setorder(dt, country, panel, wave, part_id, part_age, na.last = TRUE)
## Fill in the age group for all missing parts
dt[sample_type == "child", part_age := zoo::na.locf(part_age), by = .(country, panel, wave, part_id)]
dt[sample_type == "child", part_gender := zoo::na.locf(part_gender), by = .(country, panel, wave, part_id)]

## Remove rows of child with row_id = 0 as they are empty
dt <- dt[!(sample_type == "child" & row_id == 0)]
## change child row_id to be 0
dt[child_id == row_id, row_id := 0]


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))








    
  