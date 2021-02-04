## Name: dm100_save_locally.R
## Description: Save the comix data to my local area on my machine
## Input file: "part.qs", "part_min.qs", "households.qs", "contacts.qs"
## Functions:
## Output file: Same but also an archive file.

library(data.table)



# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')



## If running latest then check to see if the latest is equal to the most recent in all
# and then combine, if not then print warning. More uptodate data in all compared to latest.

# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
  latest <-  1 ## Change to zero if you to test all interactively
} else if(args[1] == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Updating ", ifelse(latest==0, "All", "Latest")))

# I/O Data ----------------------------------------------------------------

if(latest == 1){
  new_dta <- c("part_v3a.qs", "part_min_v3a.qs", "households_v3a.qs", "contacts_v3a.qs")
  clean_dta <- c("part_v3.qs", "part_min_v3.qs", "households_v3.qs", "contacts_v3.qs")
} else if(latest ==0){
  clean_dta <- c("part_v3.qs", "part_min_v3.qs", "households_v3.qs", "contacts_v3.qs")
}



# I/O Data ----------------------------------------------------------------

for(i in seq_along(clean_dta)){
  input <- file.path("data/clean/", clean_dta[i])
  file <- qs::qread(input)
  print(paste0("Opened: ", clean_dta[i])) 
  
  
  if(latest == 1){
    input_new <- file.path("data/clean/", new_dta[i])
    file_new <- qs::qread(input_new)

    ## Replace new data if full data is not ahead of new data
    if(max(file$survey_round) <=  max(file_new$survey_round)){
      file[survey_round != max(file_new$survey_round)]
      print("Updating with new data")
      file <- rbindlist(list(file, file_new), use.names = TRUE, fill = TRUE)
    }
  }
  #Save to local area ------------------------------------------------------
  output <- file.path(dir_data_local, clean_dta[i])
  
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  

  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, clean_dta[i], sep = "_")
  output_arc_file <- file.path(dir_data_local, "archive", output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}


