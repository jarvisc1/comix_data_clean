## Name: dm06_swap_parent_child_info.R
## Description: Parent's answer on behalf of children. Therefore need to swap
##              their information for age and gender.
## Input file: combined_5.qs
## Functions:
## Output file: combined_6.qs


# Packages ----------------------------------------------------------------
library(data.table)

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

# Identify the adult and children samples -------------------------------------------------------------

## clean sample types text
dt[, sample_type := map_sample_type[sample_type]]
## Panel A for BE, NL, and NO are all Adults
dt[ country %in% c("be", "nl", "no") & panel == "A", sample_type := "adult"]
dt[ country == "uk" & panel %in% c("A", "B"), sample_type := "adult"]
## Panel C, D for UK are children
dt[ country == "uk" & panel %in% c("C", "D"), sample_type := "child"]

dt[, sample_type := first(sample_type), by = .(country, panel, wave, part_id)]

# Identify child -------------------------------------------------------

hhm_id_pattern <- "^.*\\{_\\s*|\\s*\\}.*$"
dt[ , child_id := as.numeric(gsub(hhm_id_pattern, "", child_hhm_select_raw))]
dt[, child_id := first(child_id), by = .(country, panel, wave, part_id)]

# Swap child parent info -----------------------------------------------------------

## Swap age
# dt[sample_type == "child" & (row_id == 0),
#    parent_child := "child",
#    ]
dt[sample_type == "child" & (child_id == row_id),
   parent_child := "child"
   ]
dt[sample_type == "child" & row_id == 0,
   row_id := 999
]

dt[sample_type == "child" & row_id == 999,
   parent_child := "parent"
]
dt[sample_type == "child" &  parent_child == "child",
   row_id := 0
]

## Fill in parent's age
dt[sample_type == "child",
   hh_size := first(hh_size),
   by = .(country, panel, wave, part_id)
   ]


## Fill in parent (part_id 999) household member data from participant data
part_cols <- grep("part_[^id]", names(dt), value = T)
part_cols <- grep("hhm", part_cols, value = T, invert = T)

table(dt[parent_child == "parent"]$hhm_gender_nb, useNA = "always")
for(part_col in part_cols) {
   hhm_col <- gsub("part_", "hhm_", part_col)
   dt[parent_child == "parent", (hhm_col) := get(part_col)]
}

## Fill in child (part_id 0) partdata from hhm data
hhm_cols <- c("hhm_gender", "hhm_age_group")
table(dt[parent_child == "child"]$hhm_age_group)
table(dt[parent_child == "child"]$part_age_group)
for(hhm_col in hhm_cols) {
   part_col <- gsub("hhm_", "part_", hhm_col)
   dt[parent_child == "child", (part_col) := get(hhm_col)]
}
table(dt[parent_child == "child"]$part_age_group)

# Add adult age group
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


# LAST STEP: 
# Combine 2 parent dt rows into one for C and D (original IDS 0 and 999)

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))








    
  