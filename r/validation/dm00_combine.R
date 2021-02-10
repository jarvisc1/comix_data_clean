## Name: dm099_combine.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8.qs
## Functions:
## Output file: combined_9.qs



# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------


## Save participant data

## Could make the versions one as temporary
## versions_filepaths <- file.path(dir_date_clean, "versions")
clean_files <- list.files(dir_data_clean, full.names = TRUE)

part_files <- grep("part_v.*", clean_files, value = TRUE)
part_min_files <- grep("part_min_v.*", clean_files, value = TRUE)
contacts_files <- grep("contacts_v.*", clean_files, value = TRUE)
households_files <- grep("households_v.*", clean_files, value = TRUE)

part_list <- list()
for(i in seq_along(part_files)){
  part_list[[i]] <- qs::qread(part_files[i])
}

part_min_list <- list()
for(i in seq_along(part_min_files)){
  part_min_list[[i]] <- qs::qread(part_min_files[i])
}

contacts_list <- list()
for(i in seq_along(contacts_files)){
  contacts_list[[i]] <- qs::qread(contacts_files[i])
}

households_list <- list()
for(i in seq_along(households_files)){
  households_list[[i]] <- qs::qread(households_files[i])
}


pa <- rbindlist(part_list , use.names = TRUE, fill = TRUE)

pm <- rbindlist(part_min_list , use.names = TRUE, fill = TRUE)
ca <- rbindlist(contacts_list , use.names = TRUE, fill = TRUE)
ha <- rbindlist(households_list , use.names = TRUE, fill = TRUE)


qs::qsave(pm, file.path(dir_data_clean,"part_min.qs"))
qs::qsave(pa, file.path(dir_data_clean,"part.qs"))
qs::qsave(ca, file.path(dir_data_clean,"contacts.qs"))
qs::qsave(ha, file.path(dir_data_clean,"households.qs"))





# pa[, table(survey_round, country)]
# 
# pm[, start_date := min(date), by = .(country, survey_round)]
# 
# pm[, table(paste0(lubridate::year(start_date),"-wk", lubridate::week(start_date)), country)]
# 
# class(part_list[[3]][,168]$part_vacc_dose1_date)
# class(part_list[[4]][,126]$part_vacc_dose1_date)