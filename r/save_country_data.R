
# Save country specific data  files --------------------------------------------

library(qs)
library(data.table)

source("r/00_setup_filepaths.r")
dir.create(dir_data_local, showWarnings = F)


# dir_data_clean <- "~/../amygimma/Filr/Net Folders/EPH Shared/Comix_survey/new_do_not_remove/data/clean"

part <- as.data.table(qs::qread(file.path(dir_data_clean, "part_v5.qs")))
contacts <- as.data.table(qs::qread(file.path(dir_data_clean, "contacts_v5.qs")))
# hh <- qs::qread(file.path(dir_data_clean, "contacts_v5.qs"))

part_cols <- read.csv("codebook/part_names.csv")$cols
contact_cols <- read.csv("codebook/contact_names.csv")$cols

part <- part[, part_cols, with = F]
contacts <- contacts[, contact_cols, with = F]


for (country_name in countries) {
  part_country <- part[country == country_name]
  if (unique(part_country$country) != country_name) stop("ERROR: CHECK PART COUNTRY NAME")
  
  contacts_country <- contacts[as.character(country) == country_name]
  if (unique(contacts_country$country) != country_name) stop("ERROR: CHECK CNT COUNTRY NAME")
  
  # Save local  ---------------
  dir.create(file.path(dir_data_local, country_name), showWarnings = F)
  qsave(x = as.data.frame(part_country), 
        file = file.path(dir_data_local, country_name, paste0(country_name, "_participants.qs")))
  
  qsave(x = as.data.frame(contacts_country), 
        file = file.path(dir_data_local, country_name, paste0(country_name, "_contacts.qs")))
  
  write.csv(x = as.data.frame(part_country), 
        file = file.path(dir_data_local, country_name, paste0(country_name, "_participants.csv")),
        row.names = F)
  
  write.csv(x = as.data.frame(contacts_country), 
        file = file.path(dir_data_local, country_name, paste0(country_name, "_contacts.csv")),
        row.names = F)
  
  # Save Zipped files to filr ---------------
  
  source(pw_file_path)
  pwc <- create_pw(country_name)
  zip_file_name <- file.path("data", "clean", 
                             paste("CoMix", toupper(country_name), Sys.Date(), 
                                   sep = "_"))
  country_file_path <- file.path(dir_data_local, country_name, "*")  
  cmd <- paste0("7z a ", zip_file_name, " ",   country_file_path, " -p", pwc)
  message(paste("Zip command: ", cmd))
  system(cmd)
  
  # Save to filr ---------------
  country_remote_folder <- file.path(dir_data_clean)
  cmd <- paste0("7z a ", dir_data_clean, " ",   country_file_path, " -p", pwc)
  system(cmd)
  dir.create(file.path(dir_data_clean, country_name), showWarnings = F)
  qsave(x = as.data.frame(part_country),
        file = file.path(dir_data_clean, country_name, paste0(country_name, "_participants.qs")))

  qsave(x = as.data.frame(contacts_country),
        file = file.path(dir_data_clean, country_name, paste0(country_name, "_contacts.qs")))

  write.csv(x = as.data.frame(part_country),
            file = file.path(dir_data_clean, country_name, paste0(country_name, "_participants.csv")),
            row.names = F)

  write.csv(x = as.data.frame(contacts_country),
            file = file.path(dir_data_clean, country_name, paste0(country_name, "_contacts.csv")),
            row.names = F)

}


