
# Save country specific data  files --------------------------------------------

library(qs)
library(data.table)

source("r/00_setup_filepaths.r")
dir.create(dir_data_local, showWarnings = F)


groups <- c("g1", "g2")

for (group in groups) {
  part <- as.data.table(qs::qread(file.path(dir_data_clean, paste0("part_v4_", group,".qs"))))
  contacts <- as.data.table(qs::qread(file.path(dir_data_clean, paste0("contacts_v4_", group,".qs"))))
  part_cols <- read.csv("codebook/part_names.csv")$cols
  contact_cols <- read.csv("codebook/contact_names.csv")$cols
  part_cols <- intersect(names(part), part_cols)

  loc <- grep("qmktsize", names(part), value = TRUE)
  part_cols <- c(loc, part_cols)
  
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
    table(part_country$wave, part_country$panel, part_country$country)
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
    message(paste("Part dt saved to:", file.path(dir_data_clean, country_name, paste0(country_name, "_participants.qs"))))
    
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
