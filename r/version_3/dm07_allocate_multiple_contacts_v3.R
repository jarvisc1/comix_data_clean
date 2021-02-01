# Name: dm07_allocate_multiple_contacts.R
## Description: Assign each of the multiple contacts to a row
## Input file: combined_6_v3.qs
## Functions:
## Output file: combined_7_v3.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)
if(length(args) == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Updating ", ifelse(latest==0, "All", "Latest")))

# I/O Data ----------------------------------------------------------------

if(latest == 1){
 input_name <-  paste0("combined_6_v3a.qs")
 output_name <- paste0("combined_7_v3a.qs")
} else if(latest ==0){
 input_name <-  paste0("combined_6_v3.qs")
 output_name <- paste0("combined_7_v3.qs")
}
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 



# Find multi contacts columns ---------------------------------------------
multi <- grep("^multi", names(dt), value =TRUE)
multi <- grep("phys|precautions|duration", multi, value =TRUE, invert = TRUE)
multi <- c("country", "part_id", "panel", "wave", multi)

# Reshape to one row per contact per setting type -------------------------------------
dt_long <- melt(dt[row_id == 0, ..multi], id.vars = c("country", "part_id", "panel", "wave"))

## Remove those without multiple contacts
dt_long <- dt_long[!is.na(value)]

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


## Needed past survey round 39. May split survey round so move to another part

if("mutiple_contacts_other_duration" %in% names(dt)){  
dt_cnts[,cnt_total_time  := fifelse(cnt_other == "Yes",
                                    multiple_contacts_other_duration, NA_character_)]

dt_cnts[is.na(cnt_total_time), cnt_total_time := fifelse(cnt_work == "Yes",
                                                   multiple_contacts_work_duration, NA_character_)]

dt_cnts[is.na(cnt_total_time), cnt_total_time := fifelse(cnt_school == "Yes",
                                                   multiple_contacts_school_duration, NA_character_)]
}



dt[(!is.na(cnt_age) | hhm_contact == "Yes"), cnt_mass := "individual"]
# Append on to main data --------------------------------------------------
dt <- rbindlist(list(dt, dt_cnts), use.names = TRUE, fill = TRUE)


# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved:' , output_name))

