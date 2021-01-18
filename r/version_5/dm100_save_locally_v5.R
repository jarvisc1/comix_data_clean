## Name: dm100_save_locally.R
## Description: Save the comix data to my local area on my machine
## Input file: "part.qs", "part_min.qs", "households.qs", "contacts.qs"
## Functions:
## Output file: Same but also an archive file.





# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

clean_dta <- c("part_v5.qs", "part_min_v5.qs", "households_v5.qs", "contacts_v5.qs")


for(i in clean_dta){
  input <- file.path("data/clean", i)
  file <- qs::qread(input)
  print(paste0("Opened: ", i)) 
  

  # Save to local area ------------------------------------------------------
  output <- file.path(dir_data_local, i)
  
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  

  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, i, sep = "_")
  output_arc_file <- file.path(dir_data_local, "archive", output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}


