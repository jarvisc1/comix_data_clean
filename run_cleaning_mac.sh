# #!/bin/bash
# # Data cleaning process

echo "Install packages if needed"
Rscript "r/00_install_packages.R"

echo "Convert from SPSS to QS files"
Rscript "r/dm01_resave_spss_as_qs.R"

echo "Check and add country panel and wave variables $1"
Rscript "r/dm02_data_standardise.R"

echo "Turn from wide data to long data.table"
Rscript "r/dm03_create_datatable.R"

echo "Rename the variables"
Rscript "r/dm04_rename_vars.R"

echo "Combine all countries and waves together"
Rscript "r/dm05_combine_data.R"

echo "Swap adult and child info for parent surveys"
Rscript "r/dm06_swap_parent_child_info.R"

echo "Allocate mass contacts to contact rows"
Rscript "r/dm07_allocate_multiple_contacts.R"

echo "Clean data needs for contact analyses"
Rscript "r/dm08_clean_contacts.R"

echo "Clean location data"
Rscript "r/dm09_clean_locations.R"

echo "Clean Households"
Rscript "r/dm10_clean_household.R"

echo "Clean Participants"
Rscript "r/dm11_clean_participant.R"

echo "Save data on LSHTM server"
Rscript "r/dm101_save_remote.R"

