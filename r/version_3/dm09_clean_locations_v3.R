## Name: dm09_clean_other_vars_v3.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8_v3.qs
## Functions:
## Output file: combined_9_v3.qs



# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
  latest <-  0
} else if(args[1] == 1){
  latest <- args[1]
}

print(paste0("Updating ", ifelse(latest==0, "All", "Latest")))

# I/O Data ----------------------------------------------------------------

if(latest == 1){
  input_name <-  paste0("combined_8_v3a.qs")
  output_name <- paste0("combined_9_v3a.qs")
} else if(latest ==0){
  input_name <-  paste0("combined_8_v3.qs")
  output_name <- paste0("combined_9_v3.qs")
}


input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Maps for locations ---------------------------------------------------------------

locations <- as.data.table(readxl::read_excel('codebook/var_names.xlsx', sheet = "locations"))

map_uk_nations <- c(
  "Northern Ireland" = "Northern Ireland",
  "Scotland" = "Scotland",
  "Wales" = "Wales",
  "East of England" = "England",
  "East Midlands" = "England",
  "Greater London" = "England",
  "North East" = "England",
  "North West" = "England",
  "South East" = "England",
  "South West" = "England",
  "West Midlands" = "England",
  "Yorkshire and The Humber" = "England"
)



## area_3_name - England regions
map_area_2_name <- locations[variable == "area_2_name",]$newname
names(map_area_2_name) <- locations[variable == "area_2_name",]$oldname
map_area_3_name <- locations[variable == "area_3_name",]$newname
names(map_area_3_name) <- locations[variable == "area_3_name",]$oldname


## Update locations
dt[, area_2_name := first(area_2_name), by = .(country, panel, wave, part_id)]
dt[, area_2_name := map_area_2_name[area_2_name]]
dt[, area_3_name := first(area_3_name), by = .(country, panel, wave, part_id)]
dt[, area_3_name := map_area_3_name[area_3_name]]
dt[country == "uk", uk_nations := map_uk_nations[area_3_name]]

   
   
# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved: ' , output_name))
   