## Name: dm01_validate
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

change_file <- readxl::read_excel("codebook/validation_list.xlsx", sheet = "changes")
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



# Some people need new ids ------------------------------------------------
id_file <- readxl::read_excel("codebook/validation_list.xlsx", sheet = "new_id")
id_file <- as.data.table(id_file)

# Change age for a specific value -----------------------------------------
puid_w <- id_file$part_wave_uid

part[part_wave_uid %in% puid_w, part_id := part_id + 500000]
part[, part_uid := paste(country, part_id, sep = "_")]
part[, part_wave_uid := paste(country, paste0(panel,wave), part_id, sep = "_")]


qs::qsave(part, "data/validated/test/part_101.qs")


