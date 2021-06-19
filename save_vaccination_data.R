# 7z a ../vaccination_data.7z * -p[password]
# Save country specific data  files --------------------------------------------

library(qs)
library(data.table)

source("r/00_setup_filepaths.r")
dir.create(dir_data_local, showWarnings = F)


# Load data ==========
part <- as.data.table(qs::qread(file.path(dir_data_validate, "part.qs")))
part_min <- as.data.table(qs::qread(file.path(dir_data_validate, "part_min.qs")))
contacts <- as.data.table(qs::qread(file.path(dir_data_clean, "contacts.qs")))
households <- as.data.table(qs::qread(file.path(dir_data_clean, "households.qs")))

# Filter data ===========

# Remove Norway data for now
part <- part[country != "no"]
part_min <- part_min[country != "no"]
contacts <- contacts[country != "no"]
households <- households[country != "no"]


# Remove UK Panels A & B  (vaccination questions not asked)
part <- part[!(country == "uk" & panel %in% c("A", "B"))]
part_min <- part_min[!(country == "uk" & panel %in% c("A", "B"))]
contacts <- contacts[!(country == "uk" & panel %in% c("A", "B"))]
households <- households[!(country == "uk" & panel %in% c("A", "B"))]

# Remove BE Panel A (vaccination questions not asked)
part <- part[!(country == "be" & panel %in% c("A"))]
part_min <- part_min[!(country == "be" & panel %in% c("A"))]
contacts <- contacts[!(country == "be" & panel %in% c("A"))]
households <- households[!(country == "be" & panel %in% c("A"))]

# Remove Children's data for now
contacts <- merge(contacts, part[, list(part_wave_uid, sample_type)], by = "part_wave_uid")
households <- merge(households[, -c(153)], 
                    part[, list(part_wave_uid, sample_type)],
                    by = "part_wave_uid")

# part <- part[sample_type != "child"]
part_min <- part_min[sample_type != "child"]
contacts <- contacts[sample_type != "child"]
households <- households[sample_type != "child"]





  part_cols <- read.csv("codebook/part_names.csv")$cols
  contact_cols <- read.csv("codebook/contact_names.csv")$cols
  part_cols <- intersect(names(part), part_cols)
  
  ncol(part)
  part <- part[, ..part_cols]
  contacts <- contacts[, ..contact_cols]
  names(part)[duplicated(names(part))]
  ncol(part)
  names(part)
  
  
  
    # Save local  ---------------
    dir.create(file.path(dir_data_local), showWarnings = F)
    qsave(x = as.data.frame(part),
          file = file.path(dir_data_local, paste0("no", "_participants.qs")))
    
    qsave(x = as.data.frame(contacts),
          file = file.path(dir_data_local, paste0("no", "_contacts.qs")))
    
    qsave(x = as.data.frame(households),
          file = file.path(dir_data_local, paste0("no", "_households.qs")))
    
    qsave(x = as.data.frame(part_min),
          file = file.path(dir_data_local, paste0("no", "_participants_min.qs")))
    # ===========
    # write.csv(x = as.data.frame(part),
    #           file = file.path(dir_data_local, paste0("vacc", "_participants.csv")),
    #           row.names = F)
    # 
    # write.csv(x = as.data.frame(contacts_country),
    #           file = file.path(dir_data_local, paste0("vacc", "_contacts.csv")),
    #           row.names = F)
    # 
    # write.csv(x = as.data.frame(part_min),
    #           file = file.path(dir_data_local, paste0("vacc", "_participants_min.csv")),
    #           row.names = F)
    # 
    # write.csv(x = as.data.frame(households),
    #           file = file.path(dir_data_local, paste0("vacc", "_households.csv")),
    #           row.names = F)
    
    # Save files to filr ---------------
    # 
    dir.create(file.path(dir_data_clean), showWarnings = F)
    qsave(x = as.data.frame(part_country),
          file = file.path(dir_data_clean, paste0("no", "_participants.qs")))
    message(paste("Part dt saved to:", file.path(dir_data_clean, paste0("_participants.qs"))))

    qsave(x = as.data.frame(contacts_country),
          file = file.path(dir_data_clean, paste0("no", "_contacts.qs")))

    write.csv(x = as.data.frame(part_country),
              file = file.path(dir_data_clean, paste0("no", "_participants.csv")),
              row.names = F)

    write.csv(x = as.data.frame(contacts_country),
              file = file.path(dir_data_clean, paste0("no", "_contacts.csv")),
              row.names = F)
    
  
