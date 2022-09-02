## Name: dm09_clean_other_vars_v3.R
## Description: Clean variables not need for the contacts - less important for R.
## Input file: combined_8_v4.qs
## Functions:
## Output file: combined_9_v4.qs



# Packages ----------------------------------------------------------------
library(data.table)

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')

# I/O Data ----------------------------------------------------------------

input_name <-  paste0("combined_8_v4.qs")
output_name <- paste0("combined_9_v4.qs")
input_data <-  file.path(dir_data_process, input_name)
output_data <- file.path(dir_data_process, output_name)

dt <- qs::qread(input_data)
print(paste0("Opened: ", input_name)) 
print(paste(unique(dt$country), collapse = "\n"))

# Maps for locations ---------------------------------------------------------------

locations <- as.data.table(readxl::read_excel('codebook/var_names.xlsx', sheet = "locations"))


## area_3_name 
map_area_2_name <- locations[variable == "area_2_name",]$newname
names(map_area_2_name) <- locations[variable == "area_2_name",]$oldname
map_area_3_name <- locations[variable == "area_3_name",]$newname
names(map_area_3_name) <- locations[variable == "area_3_name",]$oldname


## Update locations
dt[, area_2_name := first(area_2_name), by = .(country, panel, wave, part_id)]
dt[, area_2_name := map_area_2_name[area_2_name]]
dt[, area_3_name := first(area_3_name), by = .(country, panel, wave, part_id)]
dt[, area_3_name := map_area_3_name[area_3_name]]


## rename ipsos location cols
qmkt <- grep("qmkt", names(dt), value = TRUE)
setnames(dt, qmkt, paste0("ipsos_", qmkt))


## consolidate region into one column
ipsos_region <- grep("ipsos_region", names(dt), value = TRUE)
  #g1
  try(dt[country=="at", ipsos_region := ipsos_region_at], silent = T)
  try(dt[country=="dk", ipsos_region := ipsos_region_dk], silent = T)
  try(dt[country=="es", ipsos_region := ipsos_region_es], silent = T)
  try(dt[country=="fr", ipsos_region := ipsos_region_fr], silent = T)
  try(dt[country=="it", ipsos_region := ipsos_region_it], silent = T)
  try(dt[country=="pl", ipsos_region := ipsos_region_pl], silent = T)
  try(dt[country=="pt", ipsos_region := ipsos_region_pt], silent = T)
  #g2
  try(dt[country=="fi", ipsos_region := ipsos_region_fi], silent = T)
  try(dt[country=="ch", ipsos_region := ipsos_region_ch], silent = T)
  try(dt[country=="gr", ipsos_region := ipsos_region_gr], silent = T)
  try(dt[country=="lt", ipsos_region := ipsos_region_lt], silent = T)
  #g3 countries did not have a column called region
  try(dt[country %in% c("ee", "hr", "hu", "mt", "sk"), ipsos_region := NA])

  
  dt[, (ipsos_region) := NULL]
  

   
# Save data ---------------------------------------------------------------
qs::qsave(dt, file = output_data)
print(paste0('Saved: ' , output_name))
   
