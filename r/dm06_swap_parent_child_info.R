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
dt[sample_type == "child" & (row_id == 0),
   parent_child := "child",
   ]
dt[sample_type == "child" & (child_id == row_id),
   parent_child := "parent",
   ]

## Fill in parent's age
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   part_age := first(part_age),
   by = .(country, panel, wave, part_id)
   ]
## Fill in child's age
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   hhm_age_group := last(hhm_age_group),
   by = .(country, panel, wave, part_id)
   ]
## Swap parent's with child's
dt[sample_type == "child" & (row_id == 0),
   part_age := hhm_age_group,
   by = .(country, panel, wave, part_id)
   ]
## Move parent to household member
dt[sample_type == "child" & (child_id == row_id),
   hhm_age_group := part_age,
   by = .(country, panel, wave, part_id)
   ]
## Remove household age for child
dt[sample_type == "child" & (row_id == 0),
   hhm_age_group := NA_character_,
   by = .(country, panel, wave, part_id)
   ]
## Remove participant age for parent
dt[sample_type == "child" & (child_id == row_id),
   part_age := NA_character_,
   by = .(country, panel, wave, part_id)
   ]

## Same as above but for gender
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   part_gender := first(part_gender),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   hhm_gender := last(hhm_gender),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   part_gender := hhm_gender,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (child_id == row_id),
   hhm_gender := part_gender,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   hhm_gender := NA_character_,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (child_id == row_id),
   part_gender := NA_character_,
   by = .(country, panel, wave, part_id)
   ]

# Swap whether household contact ------------------------------------------

# Add parent as household member contact for C and D 
## This can be removed once CD version_s code has been frozen

dt[panel %in% c("C", "D") & sample_type == "child" & (row_id == 0), hhm_contact := "Yes"]
dt[panel %in% c("C", "D") & sample_type == "child" & (row_id == 0), cnt_home := "Yes"]
dt[panel %in% c("C", "D") & sample_type == "child" & (row_id == 0), cnt_work := "No"]
dt[panel %in% c("C", "D") & sample_type == "child" & (row_id == 0), cnt_school := "No"]

dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   hhm_contact := first(hhm_contact),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   cnt_home := first(cnt_home),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   cnt_work := first(cnt_work),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0 | child_id == row_id),
   cnt_school := first(cnt_school),
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   hhm_contact := NA_character_,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   cnt_home := NA_character_,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   cnt_work := NA_character_,
   by = .(country, panel, wave, part_id)
   ]
dt[sample_type == "child" & (row_id == 0),
   cnt_school := NA_character_,
   by = .(country, panel, wave, part_id)
   ]



## also these hhm_student hhm_student_nursery hhm_student_school hhm_student_college
## hhm_student_university


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))








    
  