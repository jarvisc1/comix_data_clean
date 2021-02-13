## Take a spss_file filename and an qs file name.
## Read the spss flile and save the qs file

## Rename spss files
save_spss_qs <- function(spss_file, qs_file, spss_files, keep){
  ## Read in spss file
  spss_path <- grep(spss_file, spss_files, value = T)
  df_ <- foreign::read.spss(spss_path)
  ## Convert to data.table
  dt_ <- data.table::as.data.table(df_)
  ## Save as an rds file
  names(dt_) <- tolower(names(dt_))
  dt_ <- dt_[substr(cultureinfo,4,5)==keep]
  ## Rename V7 panels to Panel C (Ipsos assigns Panel G)
  dt_[, panel := as.character("Panel C")]

  qs_path <- file.path(dir_data_process, qs_file)
  qs::qsave(dt_, qs_path)
}

