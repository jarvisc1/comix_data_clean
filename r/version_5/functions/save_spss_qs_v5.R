## Take a spss_file filename and an qs file name.
## Read the spss flile and save the qs file

## Rename spss files
save_spss_qs <- function(spss_file, qs_file, country, keep){
  ## Read in spss file
  spss_path <- file.path(dir_data_spss, country, spss_file)
  df_ <- foreign::read.spss(spss_path)
  ## Convert to data.table
  dt_ <- data.table::as.data.table(df_)
  ## Save as an rds file
  names(dt_) <- tolower(names(dt_))
  dt_ <- dt_[substr(cultureinfo,4,5)==keep]
  qs_path <- file.path(dir_data_process, qs_file)
  qs::qsave(dt_, qs_path)
}

