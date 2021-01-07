

if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_2.sh download' to download data."
elif [ $1 == 'download' ] 
  then
  echo "Convert from SPSS to QS files"
  Rscript.exe ".\r\version_2\dm02_resave_spss_as_qs_v2.R"
  pwd
fi

echo "Check and add country panel and wave variables"
Rscript.exe ".\r\version_2\dm02_data_standardise_v2.R"

echo "Turn from wide data to long data.table"
Rscript.exe ".\r\version_2\dm03_create_datatable_v2.R"

echo "Rename the variables"
Rscript.exe ".\r\version_2\dm04_rename_vars_v2.R"

echo "Combine all countries and waves together"
Rscript.exe ".\r\version_2\dm05_combine_data_v2.R"

# echo "Add adult survey variable"
# Rscript.exe ".\r\version_2\dm06_swap_parent_child_info_v2.R"
# 
# echo "Add the multiple contacts as multiple rows"
# Rscript.exe ".\r\version_2\dm07_allocate_multiple_contacts_v2.R"
# 
# echo "Clean data needs for contact analyses"
# Rscript.exe ".\r\version_2\dm08_clean_contacts_v2.R"
# 
# echo "Clean location data"
# Rscript.exe ".\r\version_2\dm09_clean_locations_v2.R"
# 
# echo "Clean Households"
# Rscript.exe ".\r\version_2\dm20_clean_household_v2.R"
# 
# echo "Clean Participants"
# Rscript.exe ".\r\version_2\dm22_clean_participant_v2.R"
# 
# echo "Save data on LSHTM server"
# Rscript.exe ".\r\version_2\dm202_save_remote_v2.R"
 

 
