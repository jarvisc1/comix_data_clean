

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_6_mac.sh download' to download data."
elif [ $1 == 'download' ]
  then
  echo "Convert from SPSS to QS files"
  Rscript.exe "./r/version_6/dm01_resave_spss_as_qs_V6.R"
  pwd
fi

echo "Check and add country panel and wave variables"
Rscript.exe "./r/version_6/dm02_data_standardise_V6.R"

echo "Turn from wide data to long data.table"
Rscript.exe "./r/version_6/dm03_create_datatable_V6.R"

echo "Rename the variables"
Rscript.exe "./r/version_6/dm04_rename_vars_V6.R"

echo "Combine all countries and waves together"
Rscript.exe "./r/version_6/dm05_combine_data_V6.R"

echo "Add adult survey variable"
Rscript.exe "./r/version_6/dm06_swap_parent_child_info_V6.R"

echo "Add the multiple contacts as multiple rows"
Rscript.exe "./r/version_6/dm07_allocate_multiple_contacts_V6.R"

echo "Clean data needs for contact analyses"
Rscript.exe "./r/version_6/dm08_clean_contacts_V6.R"

echo "Clean location data"
Rscript.exe "./r/version_6/dm09_clean_locations_V6.R"

echo "Clean Households"
Rscript.exe "./r/version_6/dm10_clean_household_V6.R"

echo "Clean Participants"
Rscript.exe "./r/version_6/dm11_clean_participant_V6.R"

echo "Save data on LSHTM server"
Rscript.exe "./r/version_6/dm101_save_remote_V6.R"



