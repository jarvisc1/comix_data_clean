## Name: dm01_update_values
## Description: Load the cleaneded version of the data and run checks and replace inconsistent or strange values
## Input file: part.qs, contacts.qs, households.qs
## Functions: 
## Output file: part.qs, contacts.qs, households.qs but in validated folder

# Packages ----------------------------------------------------------------
library(data.table)
# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')


# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
  latest <-  1 ## Change to zero if you to test all interactively
} else if(args[1] == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Downloading ", ifelse(latest==0, "All", "Latest")))

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country <- "UK"

# Open SPSS and save as QS ------------------------------------------------

pt_path <- file.path(dir_data_clean, "part.qs")
part <- qs::qread(pt_path)
hh_path <- file.path(dir_data_clean, "households.qs")
households <- qs::qread(hh_path)
cnt_path <- file.path(dir_data_clean, "contacts.qs")
contacts <- qs::qread(cnt_path)

chg_path <- file.path(dir_data_validate, "validation_list.xlsx")
change_file <- readxl::read_excel(chg_path, sheet = "changes")
change_file <- as.data.table(change_file)





# This can work for changing values ---------------------------------------

puid <- change_file[!is.na(part_uid)]

# Change age for all values -----------------------------------------------
for (i in 1:nrow(puid)){
  uid <- puid$part_uid[i]
  var <- puid$var[i]
  new_value <- puid$new_value[i]
  set(part, i = which(part$part_uid %in% uid), j = var, value = new_value )
}


# Change age for a specific value -----------------------------------------
puid_w <- change_file[!is.na(part_wave_uid)]

# Change age for specific values -----------------------------------------------
for (i in 1:nrow(puid_w)){
  uid <- puid_w$part_wave_uid[i]
  var <- puid_w$var[i]
  new_value <- puid_w$new_value[i]
  set(part, i = which(part$part_wave_uid %in% uid), j = var, value = new_value )
}

##update part_age_group, part_age_est_min, part_age_est_max
part[sample_type=="adult" & between(part_age,18,29), part_age_group := "18-29"]
part[sample_type=="adult" & between(part_age,30,39), part_age_group := "30-39"]
part[sample_type=="adult" & between(part_age,40,49), part_age_group := "40-49"]
part[sample_type=="adult" & between(part_age,50,59), part_age_group := "50-59"]
part[sample_type=="adult" & between(part_age,60,69), part_age_group := "60-69"]
part[sample_type=="adult" & between(part_age,70,120), part_age_group := "70-120"]

part[sample_type=="adult" & between(part_age,18,29), part_age_est_min := 18]
part[sample_type=="adult" & between(part_age,30,39), part_age_est_min := 30]
part[sample_type=="adult" & between(part_age,40,49), part_age_est_min := 40]
part[sample_type=="adult" & between(part_age,50,59), part_age_est_min := 50]
part[sample_type=="adult" & between(part_age,60,69), part_age_est_min := 60]
part[sample_type=="adult" & between(part_age,70,120), part_age_est_min := 70]

part[sample_type=="adult" & between(part_age,18,29), part_age_est_max := 29]
part[sample_type=="adult" & between(part_age,30,39), part_age_est_max := 39]
part[sample_type=="adult" & between(part_age,40,49), part_age_est_max := 49]
part[sample_type=="adult" & between(part_age,50,59), part_age_est_max := 59]
part[sample_type=="adult" & between(part_age,60,69), part_age_est_max := 69]
part[sample_type=="adult" & between(part_age,70,120), part_age_est_min := 120]


# Some people need new ids (B9) ------------------------------------------------
id_file <- readxl::read_excel(chg_path, sheet = "new_id")
id_file <- as.data.table(id_file)

# Change age for a specific value -----------------------------------------
puid_w <- id_file$part_wave_uid

part[part_wave_uid %in% puid_w, part_id := part_id + 500000]
part[, part_uid := paste(country, part_id, sep = "_")]
part[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]
contacts[part_wave_uid %in% puid_w, part_id := part_id + 500000]
contacts[, part_uid := paste(country, part_id, sep = "_")]
contacts[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]
households[part_wave_uid %in% puid_w, part_id := part_id + 500000]
households[, part_uid := paste(country, part_id, sep = "_")]
households[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]

# Some people need new ids (non B9) ------------------------------------------------
id_file <- readxl::read_excel(chg_path, sheet = "other_new_id")
id_file <- as.data.table(id_file)

# Change age for a specific value -----------------------------------------
puid_w <- id_file$part_wave_uid

part[part_wave_uid %in% puid_w, part_id := part_id + 600000]
part[, part_uid := paste(country, part_id, sep = "_")]
part[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]
contacts[part_wave_uid %in% puid_w, part_id := part_id + 600000]
contacts[, part_uid := paste(country, part_id, sep = "_")]
contacts[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]
households[part_wave_uid %in% puid_w, part_id := part_id + 600000]
households[, part_uid := paste(country, part_id, sep = "_")]
households[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]


# Mark some obs as use_with_care
use_with_care <- readxl::read_excel(chg_path, sheet = "use_with_care")
use_with_care <- as.data.table(use_with_care)

puid_w <- use_with_care$id

part[part_wave_uid %in% puid_w, use_with_care := TRUE]
part[part_id %in% puid_w, use_with_care := TRUE]
contacts[part_wave_uid %in% puid_w, use_with_care := TRUE]
contacts[part_id %in% puid_w, use_with_care := TRUE]
households[part_wave_uid %in% puid_w, use_with_care := TRUE]
households[part_id %in% puid_w, use_with_care := TRUE]




# Correct household data and contacts for UK data -------------------------



# Save validated data -----------------------------------------------------
qs::qsave(part, "data/validated/part_valid.qs")
qs::qsave(households, "data/validated/households_valid.qs")
qs::qsave(contacts, "data/validated/contacts_valid.qs")




# Create_part_min ---------------------------------------------------------

vars_names <- c("part_id", 
                "part_uid",
                "part_wave_uid",
                "country",
                "panel", 
                "wave",
                "survey_round",
                "sample_type",
                "date",
                "weekday",
                "area_2_name", 
                "area_3_name", 
                "part_age",
                "part_social_group",
                "part_age_group", 
                "part_age_est_min",
                "part_age_est_max",
                "hh_size",
                "hh_size_group"
)

part_min = part[, ..vars_names]



qs::qsave(part_min, "data/validated/part_min_valid.qs")

