
# Define whether to run for all or just the latest.
new_only=0

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_3.sh download' to download data."
elif [ $1 == 'download' ]
  then
  echo "Downloading all data"
  echo "Convert from SPSS to QS files"
  Rscript "r/version_3/dm01_resave_spss_as_qs_v3.R" $new_only
  pwd
elif [ $1 == 'latest' ]
  then
  new_only=1
  echo "Downloading latest data"
  echo "Convert from SPSS to QS for most recent file"
  Rscript "r/version_3/dm01_resave_spss_as_qs_v3.R" $new_only
  pwd
fi


echo "Check and add country panel and wave variables"
Rscript "r/version_3/dm02_data_standardise_v3.R" $new_only

echo "Turn from wide data to long data.table"
Rscript "r/version_3/dm03_create_datatable_v3.R" $new_only

echo "Rename the variables"
Rscript "r/version_3/dm04_rename_vars_v3.R" $new_only

echo "Combine all countries and waves together"
Rscript "r/version_3/dm05_combine_data_v3.R" $new_only

echo "Add adult survey variable"
Rscript "r/version_3/dm06_swap_parent_child_info_v3.R" $new_only

echo "Add the multiple contacts as multiple rows"
Rscript "r/version_3/dm07_allocate_multiple_contacts_v3.R" $new_only

echo "Clean data needs for contact analyses"
Rscript "r/version_3/dm08_clean_contacts_v3.R" $new_only

echo "Clean location data"
Rscript "r/version_3/dm09_clean_locations_v3.R" $new_only

echo "Clean Households"
Rscript "r/version_3/dm10_clean_household_v3.R" $new_only
# 
echo "Clean Participants"
Rscript "r/version_3/dm11_clean_participant_v3.R" $new_only

echo "Save locally"
Rscript "r/version_3/dm100_save_locally_v3.R" $new_only

echo "Save data on LSHTM server"
Rscript "r/version_3/dm101_save_remote_v3.R" $new_only



