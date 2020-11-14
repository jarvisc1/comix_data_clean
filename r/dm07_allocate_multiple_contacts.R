# Name: dm07_allocate_multiple_contacts.R
## Description: Assign each of the multiple contacts to a row
## Input file: combined_6.qs
## Functions:
## Output file: combined_7.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_6.qs")
output_name <- paste0("combined_7.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Find multi contacts columns ---------------------------------------------
multi <- grep("^multi", names(dt), value =TRUE)
multi <- grep("phys", multi, value =TRUE, invert = TRUE)
multi <- c("country", "part_id", "panel", "wave", multi)

# Reshape to one row per contact per setting type -------------------------------------
dt_long <- melt(dt[, ..multi], id.vars = c("country", "part_id", "panel", "wave"))

## Remove those without multiple contacts
dt_long <- dt_long[!is.na(value) & value > 0]

## Expand for one row for each contact
dt_long <- dt_long[rep(seq(.N), value), !"value"]

# Set names of variables --------------------------------------------------
dt_long[, variable := gsub("multiple_contacts_", "",variable)]
dt_long[variable %like% "older_adult", cnt_age := "65+"]
dt_long[variable %like% "^adult", cnt_age := "18-64"]
dt_long[variable %like% "^child", cnt_age := "0-17"]
dt_long[variable %like% "other", setting := "cnt_other"]
dt_long[variable %like% "school", setting := "cnt_school"]
dt_long[variable %like% "work", setting := "cnt_work"]
dt_long[, value := "Yes"]

# Reshape to wide for merging ---------------------------------------------
dt_long[, cnt_id := 1:.N, by = .(country, panel, wave, part_id)]
dt_cnts <- dcast(dt_long, country+panel+wave+part_id+cnt_age+cnt_id ~ setting, value.var = "value", fill = "No")

dt_cnts$cnt_home <- "No" ## Add in that they are not home contacts.
dt_cnts$cnt_mass <- "mass"
dt_cnts$cnt_id <- NULL


# Add in precautions ------------------------------------------------------

multi_prec <- grep("^cnt_multiple_cont", names(dt), value =TRUE)
multi_prec <- c("country", "part_id", "panel", "wave", multi_prec)
dt_prec <- dt[, ..multi_prec]
dt_prec <- dt_prec[
  !is.na(cnt_multiple_contacts_other_precautions) |
  !is.na(cnt_multiple_contacts_work_precautions) |
  !is.na(cnt_multiple_contacts_school_precautions) 
    ]

dt_cnts <- merge(dt_cnts, dt_prec, all.x = TRUE, by = c("country", "panel", "wave", "part_id"))

# Combine into one precaution --------------------------------------------

dt_cnts[,cnt_prec := fifelse(cnt_other == "Yes",
    cnt_multiple_contacts_other_precautions, NA_character_)]

dt_cnts[is.na(cnt_prec),cnt_prec := fifelse(cnt_work == "Yes",
    cnt_multiple_contacts_work_precautions, NA_character_)]

dt_cnts[is.na(cnt_prec),cnt_prec := fifelse(cnt_school == "Yes",
    cnt_multiple_contacts_school_precautions, NA_character_)]

dt_cnts[, cnt_multiple_contacts_work_precautions := NULL]
dt_cnts[, cnt_multiple_contacts_school_precautions := NULL]
dt_cnts[, cnt_multiple_contacts_other_precautions := NULL]

# Append on to main data --------------------------------------------------
dt <- rbindlist(list(dt, dt_cnts), use.names = TRUE, fill = TRUE)

## Remove excess prec for multi contacts
dt[, cnt_multiple_contacts_work_precautions := NULL]
dt[, cnt_multiple_contacts_school_precautions := NULL]
dt[, cnt_multiple_contacts_other_precautions := NULL]

dt[is.na(cnt_mass) & (!is.na(cnt_age) | hhm_contact_yn == "Yes"), cnt_mass := "individual"]

# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

