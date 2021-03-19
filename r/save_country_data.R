
# Save country specific data  files --------------------------------------------

library(qs)
library(data.table)

source("r/00_setup_filepaths.r")
dir.create(dir_data_local, showWarnings = F)


# dir_data_clean <- "~/../amygimma/Filr/Net Folders/EPH Shared/Comix_survey/new_do_not_remove/data/clean"
groups <- c("g1", "g2")

for (group in groups) {
  part <- as.data.table(qs::qread(file.path(dir_data_clean, paste0("part_v4_", group,".qs"))))
  contacts <- as.data.table(qs::qread(file.path(dir_data_clean, paste0("contacts_v4_", group,".qs"))))
  # hh <- qs::qread(file.path(dir_data_clean, "contacts_v5.qs"))
  part_cols <- read.csv("codebook/part_names.csv")$cols
  contact_cols <- read.csv("codebook/contact_names.csv")$cols
  part_cols <- intersect(names(part), part_cols)

  ncol(part)
  part <- part[, ..part_cols]
  contacts <- contacts[, ..contact_cols]
  names(part)[duplicated(names(part))]
  ncol(part)

  countries <- unique(part$country)
  message(paste(countries, collapse = ", "))
  for (country_name in countries) {
    part_country <- part[country == country_name]
    part_country <- part_country[, ..part_cols]

    if (unique(part_country$country) != country_name) stop("ERROR: CHECK PART COUNTRY NAME")

    contacts_country <- contacts[as.character(country) == country_name]
    contacts_country <- contacts_country[, ..contact_cols]

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

    # Save files to filr ---------------

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
}






part <- as.data.table(qs::qread(file.path(dir_data_validate, paste0("part", ".qs"))))
contacts <- as.data.table(qs::qread(file.path(dir_data_validate, paste0("contacts", ".qs"))))
  # hh <- qs::qread(file.path(dir_data_clean, "contacts_v5.qs"))
  # 
  # part_cols <- read.csv("codebook/part_names.csv")$cols
  # contact_cols <- read.csv("codebook/contact_names.csv")$cols
  # part_cols <- intersect(names(part), part_cols)
  # 
  # ncol(part)
  # part <- part[, ..part_cols]
  # contacts <- contacts[, ..contact_cols]
  # names(part)[duplicated(names(part))]
  # ncol(part)
  
  countries <- unique(part$country)
  message(paste(countries, collapse = ", "))
  countries <- c("be", "nl")
  message(paste(countries, collapse = ", "))
  for (country_name in countries) {
    part_country <- part[country == country_name]
    # part_country <- part_country[, ..part_cols]
    
    if (unique(part_country$country) != country_name) stop("ERROR: CHECK PART COUNTRY NAME")
    
    contacts_country <- contacts[as.character(country) == country_name]
    # contacts_country <- contacts_country[, ..contact_cols]
    
    if (unique(contacts_country$country) != country_name) stop("ERROR: CHECK CNT COUNTRY NAME")
    
    # Save local  ---------------
    dir.create(file.path(dir_data_local, country_name), showWarnings = F)
    qsave(x = as.data.frame(part_country), 
          file = file.path(dir_data_local, country_name, paste0("part_", country_name, ".qs")))
    
    qsave(x = as.data.frame(contacts_country), 
          file = file.path(dir_data_local, country_name, paste0("contacts_", country_name, ".qs")))
    
    # write.csv(x = as.data.frame(part_country), 
    #           file = file.path(dir_data_local, country_name, paste0(country_name, "_participants.csv")),
    #           row.names = F)
    # 
    # write.csv(x = as.data.frame(contacts_country), 
    #           file = file.path(dir_data_local, country_name, paste0(country_name, "_contacts.csv")),
    #           row.names = F)
    
    # Save files to filr ---------------
    
    dir.create(file.path(dir_data_validate, country_name), showWarnings = F)
    qsave(x = as.data.frame(part_country),
          file = file.path(dir_data_validate, country_name, paste0("part_", country_name, ".qs")))

    qsave(x = as.data.frame(contacts_country),
    file = file.path(dir_data_validate, country_name, paste0("contacts_", country_name, ".qs")))

    # write.csv(x = as.data.frame(part_country),
    #           file = file.path(dir_data_clean, country_name, paste0(country_name, "_participants.csv")),
    #           row.names = F)
    # 
    # write.csv(x = as.data.frame(contacts_country),
    #           file = file.path(dir_data_clean, country_name, paste0(country_name, "_contacts.csv")),
              # row.names = F)
  }



