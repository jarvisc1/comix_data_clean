
if [ -z $1 ]
  then
  echo "Running local code run 'sh run_version_7_mac.sh NLdownload OR sh run_version_7_mac.sh BEdownload' to download G1 data or country_codes1 or country_codes3."
elif [ $1 == 'BEdownload' ]
  then
  country_codes="BE"
  echo "Convert from SPSS to QS files"
  Rscript "r/version_7/dm01_resave_spss_as_qs_v7.R" $country_codes
  pwd
elif [ $1 == 'NLdownload' ]
  then
  country_codes="NL"
  echo "Convert from SPSS to QS files"
  Rscript "r/version_7/dm01_resave_spss_as_qs_v7.R" $country_codes
  pwd
else
  country_codes=$1
fi


echo "Check and add country panel and wave variables"
Rscript "r/version_7/dm02_data_standardise_v7.R" $country_codes

echo "Turn from wide data to long data.table"
Rscript "r/version_7/dm03_create_datatable_v7.R" $country_codes

echo "Rename the variables"
Rscript "r/version_7/dm04_rename_vars_v7.R" $country_codes

echo "Combine all countries and waves together"
Rscript "r/version_7/dm05_combine_data_v7.R" $country_codes

echo "Add adult survey variable"
Rscript "r/version_7/dm06_swap_parent_child_info_v7.R"

echo "Add the multiple contacts as multiple rows"
Rscript "r/version_7/dm07_allocate_multiple_contacts_v7.R"

echo "Clean data needs for contact analyses"
Rscript "r/version_7/dm08_clean_contacts_v7.R"

echo "Clean location data"
Rscript "r/version_7/dm09_clean_locations_v7.R"

echo "Clean Households"
Rscript "r/version_7/dm10_clean_household_v7.R"

echo "Clean Participants"
Rscript "r/version_7/dm11_clean_participant_v7.R"

echo "Save data on ;ocally"
Rscript "r/version_7/dm100_save_locally_v7.R" $country_codes

echo "Save data on LSHTM server"
Rscript "r/version_7/dm101_save_remote_v7.R" $country_codes


