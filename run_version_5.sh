country="BE"

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_5.sh download' to download data."
elif [ $1 == 'download' ]
  then
  echo "Convert from SPSS to QS files"
  Rscript.exe "./r/version_5/dm01_resave_spss_as_qs_v5.R" $country
  pwd
fi

echo "Check and add country panel and wave variables"
Rscript.exe "r/version_5/dm02_data_standardise_v5.R" $country

echo "Turn from wide data to long data.table"
Rscript.exe "./r/version_5/dm03_create_datatable_v5.R" $country

echo "Rename the variables"
Rscript.exe "./r/version_5/dm04_rename_vars_v5.R" $country

echo "Combine all countries and waves together"
Rscript.exe "./r/version_5/dm05_combine_data_v5.R" $country

echo "Add adult survey variable"
Rscript.exe "./r/version_5/dm06_swap_parent_child_info_v5.R"

echo "Add the multiple contacts as multiple rows"
Rscript.exe "./r/version_5/dm07_allocate_multiple_contacts_v5.R"

echo "Clean data needs for contact analyses"
Rscript.exe "./r/version_5/dm08_clean_contacts_v5.R"

echo "Clean location data"
Rscript.exe "./r/version_5/dm09_clean_locations_v5.R"

echo "Clean Households"
Rscript.exe "./r/version_5/dm10_clean_household_v5.R"

echo "Clean Participants"
Rscript.exe "./r/version_5/dm11_clean_participant_v5.R"

echo "Save data locally"
Rscript.exe "./r/version_5/dm100_save_locally_v5.R" $country

# echo "Save data on LSHTM server"
# Rscript.exe "./r/version_5/dm101_save_remote_v5.R" $country


 
