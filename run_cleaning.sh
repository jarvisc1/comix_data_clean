
# Data cleaning process

echo "Convert from SPSS to QS files"
Rscript.exe ".\r\dm01_resave_spss_as_qs.R"

echo "Check and add country panel and wave variables"
Rscript.exe ".\r\dm02_data_standardise.R"

echo "Turn from wide data to long data.table"
Rscript.exe ".\r\dm03_create_datatable.R"

echo "Rename the variables"
Rscript.exe ".\r\dm04_rename_vars.R"

echo "Combine all countries and waves together"
Rscript.exe ".\r\dm05_combine_data.R"

echo "Clean existing variables"

echo "Add new variables"