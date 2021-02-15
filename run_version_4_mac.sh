country="NL"

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_4.sh download' to download data."
elif [ $1 == 'download' ]
  then
  echo "Convert from SPSS to QS files"
  Rscript "r/version_4/dm01_resave_spss_as_qs_v4.R" $country
  pwd
fi

echo "Check and add country panel and wave variables"
Rscript "r/version_4/dm02_data_standardise_v4.R" $country

echo "Turn from wide data to long data.table"
Rscript "r/version_4/dm03_create_datatable_v4.R" $country

echo "Rename the variables"
Rscript "r/version_4/dm04_rename_vars_v4.R" $country

echo "Combine all countries and waves together"
Rscript "r/version_4/dm05_combine_data_v4.R" $country

echo "Add adult survey variable"
Rscript "r/version_4/dm06_swap_parent_child_info_v4.R"

echo "Add the multiple contacts as multiple rows"
Rscript "r/version_4/dm07_allocate_multiple_contacts_v4.R"

echo "Clean data needs for contact analyses"
Rscript "r/version_4/dm08_clean_contacts_v4.R"

echo "Clean location data"
Rscript "r/version_4/dm09_clean_locations_v4.R"

echo "Clean Households"
Rscript "r/version_4/dm10_clean_household_v4.R"

echo "Clean Participants"
Rscript "r/version_4/dm11_clean_participant_v4.R"

echo "Save data locally"
Rscript "r/version_4/dm100_save_locally_v4.R" $country

echo "Save data on LSHTM server"
Rscript "r/version_4/dm101_save_remote_v4.R" $country



