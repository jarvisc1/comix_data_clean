
# Data cleaning process

echo "Convert from SPSS to QS files"
Rscript.exe ".\r\dm01_resave_spss_as_qs.R"

echo "Check and add country panel and wave variables"
Rscript.exe ".\r\dm02_add_cnty_panel_wave_all.R"

