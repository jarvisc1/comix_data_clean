## Name: dm05_combine_data_v3.R
## Description: Combine all of the temporary cleaning data into one qs file
## Input file: cnty_wkN_yyyymmdd_pN_wvN_4.qs
## Functions:
## Output file: combined_5_v3.qs


# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

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

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country <- "UK"

# Cleaning ----------------------------------------------------------------
dt_list <- list()

print(paste0("Start: ", country))

# Setup input and output data and filepaths -------------------------------
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name) &
                         filenames$survey_version == 3,]

## create a version a if just for the latest data
if(latest == 1){
  filenames <- tail(filenames, 1)
  output_name <- paste0("combined_5_v3a.qs")
} else if(latest ==0){
  output_name <- paste0("combined_5_v3.qs")
}

r_names <- filenames$r_name

for(r_name in r_names){
  input_name <-  paste0(r_name, "_4.qs")
  input_data <-  file.path(dir_data_process, input_name)
  output_data <- file.path(dir_data_process, output_name)

  dt <- qs::qread(input_data)
  #print(paste0("Opened: ", input_name))

  dt_list[[r_name]] <- dt
}


dt_combined <- rbindlist(dt_list, use.names = TRUE, fill = TRUE)

## Save combined file
qs::qsave(dt_combined, file = output_data)
print(paste0('Saved:' , output_name))
