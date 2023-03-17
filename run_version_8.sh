
# Define whether to run for all or just the latest.
new_only=0

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_8.sh download' to download data."
elif [ $1 == 'download' ]
  then
  echo "Downloading all data"
  echo "Convert from SPSS to QS files"
  Rscript.exe ".\r\version_8\dm01_resave_spss_as_qs_v8.R" $new_only
  pwd
elif [ $1 == 'latest' ]
  then
  new_only=1
  echo "Downloading latest data"
  echo "Convert from SPSS to QS for most recent file"
  Rscript.exe ".\r\version_8\dm01_resave_spss_as_qs_v8.R" $new_only
  pwd
fi


echo "Check and add country panel and wave variables"
Rscript.exe ".\r\version_8\dm02_data_standardise_v8.R" $new_only

echo "Turn from wide data to long data.table"
Rscript.exe ".\r\version_8\dm03_create_datatable_v8.R" $new_only

echo "Rename the variables"
Rscript.exe ".\r\version_8\dm04_rename_vars_v8.R" $new_only

echo "Combine all countries and waves together"
Rscript.exe ".\r\version_8\dm05_combine_data_v8.R" $new_only

echo "Add adult survey variable"
Rscript.exe ".\r\version_8\dm06_swap_parent_child_info_v8.R" $new_only

echo "Add the multiple contacts as multiple rows"
Rscript.exe ".\r\version_8\dm07_allocate_multiple_contacts_v8.R" $new_only

echo "Clean data needs for contact analyses"
Rscript.exe ".\r\version_8\dm08_clean_contacts_v8.R" $new_only

echo "Clean location data"
Rscript.exe ".\r\version_8\dm09_clean_locations_v8.R" $new_only

echo "Clean Households"
Rscript.exe ".\r\version_8\dm10_clean_household_v8.R" $new_only

echo "Clean Participants"
Rscript.exe ".\r\version_8\dm11_clean_participant_v8.R" $new_only

echo "Save locally"
Rscript.exe ".\r\version_8\dm100_save_locally_v8.R" $new_only

echo "Save data on LSHTM server"
Rscript.exe ".\r\version_8\dm101_save_remote_v8.R" $new_only



