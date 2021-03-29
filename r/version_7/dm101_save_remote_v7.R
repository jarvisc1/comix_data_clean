## Name: dm101_save_remote_v7.R
## Description: Save the comix data to my remote filer machine for version 1
## Input file: "part.qs", "part_min.qs", "households.qs", "contacts.qs"
## Functions:
## Output file: Same but also an archive file.




# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------
# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("country_codes") ) country_codes <- "NL"
if(length(args) == 1) country_codes <- args

clean_dta_names <- c("part_v7", "part_min_v7", "households_v7", "contacts_v7")
clean_dta <- paste0(clean_dta_names, ".qs")
save_dta <- paste0(clean_dta_names, "_", tolower(country_codes), ".qs")


for(i in 1:length(clean_dta)){
  input <- file.path("data/clean/", clean_dta[i])
  file <- qs::qread(input)
  print(paste0("Opened: ", clean_dta[i])) 
  

  # Save to local area ------------------------------------------------------
  output <- file.path(dir_data_clean, save_dta[i])
  
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  

  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, save_dta[i], sep = "_")
  output_arc_file <- file.path(dir_data_archive, output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}

