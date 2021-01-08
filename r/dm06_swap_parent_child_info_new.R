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
t <- Sys.time()

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
dt[, mixed_data := NA]
dt[sample_type == "child" & panel %in% c("C", "D") & row_id %in% c(0), mixed_data := T]
dt[sample_type == "child" & !(panel %in% c("C", "D")) & row_id %in% c(0), mixed_data := T]



dt[sample_type == "child" & row_id == 999,
   parent_child := "parent"
]
dt[sample_type == "child" & row_id == 0 & !panel %in% c("C", "D"),
   parent_child := "parent"
]
dt[sample_type == "child" & row_id == 0 & parent_child == "parent", row_id := 999]

dt[sample_type == "child" & parent_child == "child", row_id := 0]
table(dt$parent_child, dt$mixed_data, dt$panel, useNA = "always")

## Fill in household size
dt[sample_type == "child",
   hh_size := first(hh_size),
   by = .(country, panel, part_id)
]

table(dt[parent_child == "child"]$hh_size)

## Fill in parent (part_id 999) household member data from participant data
parent_original_cols <- 
  c("part_age", "part_employstatus",  "part_ethnicity", "part_ethnicity2", 
    "part_gender", "part_gender_nb", "part_income", "part_no_contacts", "part_occupation", 
    "part_reported_all_contacts", "part_social_group", "part_ukitv")
    


# parent_cols <- c(parent_original_cols)
# mixed_data_dt <- dt[mixed_data == T]
# table(mixed_data_dt$panel, useNA = "always")
parent_hhm_cols <- gsub("part_", "hhm_", parent_cols)
byvars <- c("row_id", "part_id", "country_code", "panel", "wave")
hhm_data_dt <- dt[mixed_data == T, c(byvars, parent_cols), with = F]
setnames(hhm_data_dt, old = parent_cols, new = parent_hhm_cols )
hhm_data_dt[, row_id := 999]

parent_dt <- merge(dt, hhm_data_dt, byvars = byvars, all = T)
table(parent_dt$parent_child)
table(parent_dt[row_id == 999]$hhm_social_group, useNA = "always")
nrow(dt)
nrow(parent_dt)
## Fill in child (part_id 0) partdata from hhm data
hhm_cols <- c("hhm_gender", "hhm_age_group")
for(hhm_col in hhm_cols) {
  part_col <- gsub("hhm_", "part_", hhm_col)
  dt[parent_child == "child", (part_col) := get(hhm_col)]
}

## Fill in child data (part_id 0) from mixed_data row
child_part_cols  <- 
  c("area_1_name","area_2_name", "area_3_name",  "area_4_name", 
    "area_5_name", "area_pop_dens_1_label", "area_pop_dens_2_label", 
    "area_rural_urban_label", "area_town_label", "area_town_pop_label", "area_tv_station", 
    "part_attend_school_yesterday", "part_face_mask",
    "part_public_transport_boat", "part_public_transport_bus", "part_public_transport_bus_hours", 
    "part_public_transport_bus_mins", "part_public_transport_no", 
    "part_public_transport_plane", "part_public_transport_plane_hours", 
    "part_public_transport_plane_mins", "part_public_transport_taxi_uber", 
    "part_public_transport_taxi_uber_hours", "part_public_transport_taxi_uber_mins", 
    "part_public_transport_train", "part_public_transport_train_hours", 
    "part_public_transport_train_mins", "part_school_class_size", 
    "part_social_group", "part_social_group1", "part_social_group2", 
    "uk_region1", "uk_region2", "uk_region3", "uk_region3_label", 
    "uk_stdregion", "ukregion1", "ukstdregion")

multiple_contact_cols <- grep("multiple_contacts_*.[^precautions]", names(dt), value = T)
child_part_cols  <- c(child_part_cols, multiple_contact_cols)

for(child_part_col in child_part_cols) {
  dt[sample_type == "child" & (row_id == 0 | mixed_data == T), 
     (child_part_col) := first(get(child_part_col)), 
     by = .(part_id, panel, wave, country)]
}


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




message(Sys.time() - t)

table(dt[parent_child == "child"]$hhm_age_group)
table(dt[parent_child == "child"]$part_age_group, useNA = "always")
table(dt[sample_type == "child" &  panel %in% c("C", "F") & row_id == 0]$part_public_transport_bus)
table(dt[parent_child == "parent"]$hhm_age_group)
table(dt[row_id == 999]$hhm_gender_nb, useNA = "always")
table(dt[row_id == 999]$hhm_gender_nb,
      dt[ row_id == 999]$panel, useNA = "always")


table(dt[parent_child == "child"]$part_face_mask, 
      dt[parent_child == "child"]$panel, useNA = "always")
table(dt[parent_child == "child"]$row_id)
table(dt[parent_child == "parent"]$cnt_work,
      dt[parent_child == "parent"]$panel, useNA = "always")
table(dt[parent_child == "parent"]$row_id)

dt[part_id == 30001 & wave == 1 & row_id %in% c(0,999) & !(parent_child == "parent" & is.na(hhm_contact)),
   list(part_id, panel, wave, row_id, parent_child, mixed_data, cnt_work, cnt_frequency, hhm_contact)]
dt[part_id == 50002 & wave == 1 & row_id %in% c(0,999),
   list(part_id, panel, wave, row_id, parent_child, mixed_data, hhm_gender, part_gender)]
## IMPORTANT
## Remove now-reduntant mixed_data row
dt <- dt[!(parent_child == "parent" & is.na(hhm_contact))]

# duplicate?

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))









