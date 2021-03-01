
if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_4.sh Group1' or sh 'run_version_4.sh Group1download' to download Group1 data"
elif [ $1 == 'G1download' ]
  then
  group="G1"
  echo "Convert from SPSS to QS files"
  Rscript.exe "./r/version_4/dm01_resave_spss_as_qs_v4.R" $group
  pwd
elif [ $1 == 'G2download' ]
  then
  group="G2"
  echo "Convert from SPSS to QS files"
  Rscript.exe "./r/version_4/dm01_resave_spss_as_qs_v4.R" $group
  pwd
else
  group=$1
fi

echo "Check and add country panel and wave variables"
Rscript.exe "./r/version_4/dm02_data_standardise_v4.R" $group

echo "Turn from wide data to long data.table"
Rscript.exe "./r/version_4/dm03_create_datatable_v4.R" $group

echo "Rename the variables"
Rscript.exe "./r/version_4/dm04_rename_vars_v4.R" $group

echo "Combine all countries and waves together"
Rscript.exe "./r/version_4/dm05_combine_data_v4.R" $group

echo "Add adult survey variable"
Rscript.exe "./r/version_4/dm06_swap_parent_child_info_v4.R"

echo "Add the multiple contacts as multiple rows"
Rscript.exe "./r/version_4/dm07_allocate_multiple_contacts_v4.R"

echo "Clean data needs for contact analyses"
Rscript.exe "./r/version_4/dm08_clean_contacts_v4.R"

echo "Clean location data"
Rscript.exe "./r/version_4/dm09_clean_locations_v4.R"

echo "Clean Households"
Rscript.exe "./r/version_4/dm10_clean_household_v4.R"

echo "Clean Participants"
Rscript.exe "./r/version_4/dm11_clean_participant_v4.R"

echo "Save data on LSHTM server"
Rscript.exe "./r/version_4/dm101_save_remote_v4.R" $group



