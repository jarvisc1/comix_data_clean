#!/bin/bash
# Data cleaning process

# echo "Install packages if needed"
# Rscript.exe ".\r\dm00_install_packages.R"
# 
# echo "Convert from SPSS to QS files"
# Rscript.exe ".\r\dm01_resave_spss_as_qs.R"
# 
#  echo "Check and add country panel and wave variables $1"
#  Rscript.exe ".\r\dm02_data_standardise.R"
#  
#  echo "Turn from wide data to long data.table"
#  Rscript.exe ".\r\dm03_create_datatable.R"

# echo "Rename the variables"
# Rscript.exe ".\r\dm04_rename_vars.R"

# echo "Combine all countries and waves together"
# Rscript.exe ".\r\dm05_combine_data.R"
# 
# echo "Swap adult and child info for parent surveys"
# Rscript.exe ".\r\dm06_swap_parent_child_info.R"
# 
# echo "Allocate mass contacts to contact rows"
# Rscript.exe ".\r\dm07_allocate_multiple_contacts.R"
# 
# echo "Clean data needs for contact analyses"
# Rscript.exe ".\r\dm08_clean_contacts.R"

echo "Clean location data"
Rscript.exe ".\r\dm09_clean_locations.R"

echo "Clean Households"
Rscript.exe ".\r\dm10_clean_household.R"

echo "Clean Participants"
Rscript.exe ".\r\dm11_clean_participant.R"


echo "Save data on LSHTM server"
Rscript.exe ".\r\dm101_save_remote.R"
 
