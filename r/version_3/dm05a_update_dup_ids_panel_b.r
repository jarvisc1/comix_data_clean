



part <- dt_combined[panel == "B" & row_id == 0]

# Look at repeated ID in panel B -----------------------------------------------------

part[, temp_genderchange := length(unique(part_gender)) > 1, by="part_id"]
part[, temp_largeareachange := length(unique(area_1_name)) > 1, by="part_id"]
part[, temp_agechange_gt1 := (max(as.numeric(part_age)) - min(as.numeric(part_age))) > 1, by="part_id"]
part[, temp_agechange_mag := (max(as.numeric(part_age)) - min(as.numeric(part_age))) , by="part_id"]

## Panel B had something weird happen. Let's move all of them to have higher ID numbers
table(part$country, part$panel)
part[, temp_id := paste0(part_age,part_gender, area_1_name)]
## Create a temp id for wave 9 in panel B
part[panel == "B" & country == "uk" & wave == 9, temp_w9_id := temp_id]
## Fill in for the rest of the data
part[panel == "B" & country == "uk", temp_w9_id := last(temp_w9_id), by = part_id]
## Count the number of rows where they do not match
part[panel == "B" & country == "uk" &!is.na(temp_w9_id), temp_n_mismatch := sum(temp_id != temp_w9_id, na.rm = TRUE), by = part_id]

## Add 500,000 to the ids that are different from wave 9 compared to wave 1
## Will only have if there is a mismatch between 

## If their  age has changed by more than a year and their gender changed then record
pids <- part[(temp_agechange_gt1 == TRUE | temp_genderchange== TRUE) & temp_n_mismatch>1 & wave ==9,]$part_id

length(pids) # gives 812


## For checking
# head(part[(temp_agechange_gt1 == FALSE | temp_genderchange== FALSE) & temp_n_mismatch>1 & temp_agechange_mag > 3, 
#           .(part_id,temp_agechange_gt1, temp_agechange_mag,wave, temp_id, temp_w9_id, part_income, temp_n_mismatch)][order(part_id)], 20)
# head(part[temp_agechange_gt1 == TRUE & temp_genderchange== TRUE & temp_n_mismatch>1, 
#           .(part_id,temp_agechange_gt1, temp_agechange_mag,wave, temp_id, temp_w9_id, part_income, temp_n_mismatch)][order(part_id)], 30)
