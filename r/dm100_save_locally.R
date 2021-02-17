## Name: dm100_save_locally.R
## Description: Save the comix data to my local area on my machine
## Input file: "part.qs", "part_min.qs", "households.qs", "contacts.qs"
## Functions:
## Output file: Same but also an archive file.


library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_valid_dta <- c("part_valid.qs", "part_min_valid.qs", "households_valid.qs", "contacts_valid.qs")

output_valid_dta <- c("part.qs", "part_min.qs", "households.qs", "contacts.qs")



for(i in seq_along(input_valid_dta)){
  input <- file.path("data/validated", input_valid_dta[i])
  file <- qs::qread(input)
  print(paste0("Opened: ", input_valid_dta[i])) 
  
  # Save to remote area ------------------------------------------------------
  output <- file.path(dir_data_local, output_valid_dta[i])
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  
  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, output_valid_dta[i], sep = "_")
  output_arc_file <- file.path(dir_data_local, "archive", output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}

