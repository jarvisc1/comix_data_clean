# 7z a ../norwayrway_data.7z * -penter-strong-password
# Save country specific data  files --------------------------------------------

library(qs)
library(data.table)

source("r/00_setup_filepaths.r")
dir.create(dir_data_local, showWarnings = F)


# Load data ==========
part <- as.data.table(qs::qread(file.path(dir_data_clean, "part_v9.qs")))
part_min <- as.data.table(qs::qread(file.path(dir_data_clean, "part_min_v9.qs")))
contacts <- as.data.table(qs::qread(file.path(dir_data_clean, "contacts_v9.qs")))
households <- as.data.table(qs::qread(file.path(dir_data_clean, "households_v9.qs")))

# Filter data ===========



table(part$country)

table(part_min$country)

table(contacts$country)

table(households$country)
table(part$norway_green_spaces_freq_82, part$wave)
table(part$norway_green_spaces_active_83, part$wave)
table(part$norway_green_spaces_important_84, part$wave)
table(part$norway_green_spaces_compliance_85, part$wave)
table(part$norway_green_spaces_comfort_86, part$wave)

# save local
# 
# dir.create(file.path(dir_data_local), showWarnings = F)
# qsave(x = as.data.frame(part),
#       file = file.path(dir_data_local, paste0("norway", "_participants.qs")))
# 
# qsave(x = as.data.frame(contacts),
#       file = file.path(dir_data_local, paste0("norway", "_contacts.qs")))
# 
# qsave(x = as.data.frame(households),
#       file = file.path(dir_data_local, paste0("norway", "_households.qs")))
# 
# qsave(x = as.data.frame(part_min),
#       file = file.path(dir_data_local, paste0("norway", "_participants_min.qs")))
# 
# 
# # save filr
# 
# dir.create(file.path(dir_data_clean), showWarnings = F)
# qsave(x = as.data.frame(part_country),
#       file = file.path(dir_data_clean, paste0("norway", "_participants.qs")))
# message(paste("Part dt saved to:", file.path(dir_data_clean, paste0("_participants.qs"))))
# 
# qsave(x = as.data.frame(contacts_country),
#       file = file.path(dir_data_clean, paste0("norway", "_contacts.qs")))
# 
# write.csv(x = as.data.frame(part_country),
#           file = file.path(dir_data_clean, paste0("norway", "_participants.csv")),
#           row.names = F)
# 
# write.csv(x = as.data.frame(contacts_country),
#           file = file.path(dir_data_clean, paste0("norway", "_contacts.csv")),
#           row.names = F)