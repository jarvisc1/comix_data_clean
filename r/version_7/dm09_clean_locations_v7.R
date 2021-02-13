## Name: dm09_clean_other_vars_v3.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8_v7.qs
## Functions:
## Output file: combined_9_v7.qs



# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_8_v7.qs")
output_name <- paste0("combined_9_v7.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 

# Maps for locations ---------------------------------------------------------------

locations <- as.data.table(readxl::read_excel('codebook/var_names.xlsx', sheet = "locations"))


## area_3_name 
map_area_2_name <- locations[variable == "area_2_name",]$newname
names(map_area_2_name) <- locations[variable == "area_2_name",]$oldname
map_area_3_name <- locations[variable == "area_3_name",]$newname
names(map_area_3_name) <- locations[variable == "area_3_name",]$oldname


## Update locations
# dt[, area_2_name := first(area_2_name), by = .(country, panel, wave, part_id)]
# dt[, area_2_name := map_area_2_name[area_2_name]]
dt[, area_3_name := first(area_3_name), by = .(country, panel, wave, part_id)]
dt[, area_3_name := map_area_3_name[area_3_name]]


   
   
# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved: ' , output_name))
   