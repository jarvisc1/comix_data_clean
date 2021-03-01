## Name: dm101_save_remote_v6.R
## Description: Save the comix data to my remote filer machine for version 1
## Input file: "part.qs", "part_min.qs", "households.qs", "contacts.qs"
## Functions:
## Output file: Same but also an archive file.




# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------
# Countries ---------------------------------------------------------------
country <- "NL"

clean_dta <- c("part_v6", "part_min_v6", "households_v6", "contacts_v6")
input_clean_dta <- paste0(clean_dta, ".qs")
output_clean_dta <- paste0(clean_dta, "_", tolower(country), ".qs")


for(i in 1:length(clean_dta)){
  input <- file.path("data/clean/", input_clean_dta[i])
  file <- qs::qread(input)
  print(paste0("Opened: ", input_clean_dta[i])) 
  

  # Save to local area ------------------------------------------------------
  output <- file.path(dir_data_clean, output_clean_dta[i])
  
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  

  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, output_clean_dta[i], sep = "_")
  output_arc_file <- file.path(dir_data_archive, output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}

