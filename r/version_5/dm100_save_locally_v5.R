## Name: dm100_save_locally.R
## Description: Save the comix data to my local area on my machine
## Input file: "part_v5_*.qs", "part_min_v5_*.qs", "households_v5_*.qs", "contacts_v5_*.qs"
## Functions:
## Output file: Same but also an archive file.



# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("group")) group <- "Group1"
if (length(args) == 1) group <- args
print(paste0("Start: ", group))

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

clean_dta <- c("part_v5", "part_min_v5", "households_v5", "contacts_v5")
input_clean_dta <- paste0(clean_dta, ".qs")
output_clean_dta <- paste0(clean_dta, "_", tolower(group), ".qs")

for(i in 1:length(clean_dta)){
  input <- file.path("data/clean", input_clean_dta[i])
  file <- qs::qread(input)
  print(paste0("Opened: ", input_clean_dta[i])) 
  
  
  # Save to local area ------------------------------------------------------
  output <- file.path(dir_data_local, output_clean_dta[i])
  
  qs::qsave(file, output)
  print(paste0("Copied to: ", output)) 
  
  
  # Save an archive ---------------------------------------------------------
  current_date <- Sys.Date()
  output_arc <- paste(current_date, output_clean_dta[i], sep = "_")
  output_arc_file <- file.path(dir_data_local, "archive", output_arc)
  qs::qsave(file, output_arc_file)
  print(paste0("Saved: ", output_arc_file)) 
}


