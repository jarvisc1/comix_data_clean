## Name: dm01_validate
## Description: Load the cleaneded version of the data and run checks and replace inconsistent or strange values
## Input file: part.qs, contacts.qs, households.qs
## Functions: 
## Output file: part.qs, contacts.qs, households.qs but in validated folder

# Packages ----------------------------------------------------------------
library(data.table)
# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')


# Get arguments -----------------------------------------------------------
args = commandArgs(trailingOnly=TRUE)

if(length(args) == 0){
   latest <-  1 ## Change to zero if you to test all interactively
} else if(args[1] == 0){
   latest <-  0
} else if(args[1] == 1){
   latest <- args[1]
}

print(paste0("Downloading ", ifelse(latest==0, "All", "Latest")))

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country <- "UK"

# Open SPSS and save as QS ------------------------------------------------

part <- qs::qread("data/validated/test/part_101.qs")


# For the moment focus on UK ----------------------------------------------
part <-  part[country == "uk" & panel %in% c("E", "F") & sample_type == "adult"]

part[, n := .N, by = part_uid]


# Check for changes in age ------------------------------------------------
part[, t_age_chge_gt1 := (max(as.numeric(part_age)) - min(as.numeric(part_age))) > 1, by="part_uid"]
part[, t_agecat_chge := length(unique(part_age_group)) > 1, by="part_uid"]
## If changing to deal with age in validation then change above to this
# part[, t_agecat_chge := length(unique(part_age)) > 1, by="part_uid"]

check_age <- part[t_age_chge_gt1 == TRUE,
     .(panel, part_wave_uid, part_uid, n, wave, t_age_chge_gt1, t_agecat_chge,
       part_age, part_age_group, part_gender, part_gender_nb, area_1_name, area_3_name, part_uid, var = "part_age" )]


check_age <- check_age[order(-t_age_chge_gt1, panel, -n, part_uid,  wave,)]

write.csv(check_age, file = 'data/validated/test/01_check_ages.csv', row.names = FALSE)


# # End age check -----------------------------------------------------------
# 
# 
# # Check for changes in gender ---------------------------------------------
# 
# part[, t_gen_chge := length(unique(part_gender)) > 1, by="part_uid"]
# part[, t_gennb_chge := length(unique(part_gender_nb)) > 1, by="part_uid"]
# check_gen <- part[t_gen_chge == TRUE | t_gennb_chge == TRUE,
#      .(panel, wave, part_wave_uid, part_uid, t_gen_chge,t_gennb_chge,
#        part_age, part_age_group, part_gender, part_gender_nb, area_1_name, area_3_name )]
# 
# check_gen <- check_gen[order(-t_gen_chge, panel, wave, part_uid)]
# 
# 
# 
# # End gender check --------------------------------------------------------
# 
# 
# 
# # Check for changes in area -----------------------------------------------
# part[, t_area1_chge := length(unique(area_1_name)) > 1, by="part_uid"]
# part[, t_area3_chge := length(unique(area_3_name)) > 1, by="part_uid"]
# 
# 
# check_location <- part[t_area3_chge == TRUE | t_age_chge_gt1 == TRUE | t_agecat_chge == TRUE | t_hr_chge ==TRUE,
#      .(panel, wave, part_wave_uid, part_uid,  t_age_chge_gt1, t_agecat_chge, t_gen_chge,t_gennb_chge,t_area3_chge,t_hr_chge,
#        part_age, part_age_group, part_gender, part_gender_nb, area_1_name, area_3_name )]
# 
# check_age <- part[t_gen_chge == TRUE | t_gennb_chge == TRUE | t_area3_chge == TRUE | t_age_chge_gt1 == TRUE | t_agecat_chge == TRUE | t_hr_chge ==TRUE,
#      .(panel, wave, part_wave_uid, part_uid,  t_age_chge_gt1, t_agecat_chge, t_gen_chge,t_gennb_chge,t_area3_chge,t_hr_chge,
#        part_age, part_age_group, part_gender, part_gender_nb, area_1_name, area_3_name )]
# 
# 
# 
# 
# 
# 
# 
# part[, t_hr_chge := length(unique(part_high_risk)) > 1, by="part_uid"]
# 

# These could change but might identify some other issues income, social group, small area
part[, temp_inc_chge := length(unique(part_income)) > 1, by="part_uid"]
part[, temp_sc_chge := length(unique(part_social_group)) > 1, by="part_uid"]