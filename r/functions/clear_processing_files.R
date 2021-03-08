# Clears data processing directory of version/country-specific files to start fresh 


# file_index = a reference to grep to remove files (version or country abbrev), 
   # can be a regex (eg "nl|v6")
# processing_dir = data processing directory to remove files from

clear_processing_files <- function(file_index, processing_dir) {
  if(!grepl("[a-z]", tolower(file_index))) stop("file_index too vague, specify version (eg 'v6') or country")
  processing_files <- list.files(processing_dir)
  rm_files <- grep(file_index, processing_files, value = T)
  # rm_files <- grep("")
  message(paste(c("Removing files:", rm_files), collapse = "\n"))
  file.remove(file.path(processing_dir, rm_files))
}



# Common calls
# clear_processing_files("be|v5", dir_data_process)
# clear_processing_files("nl|v6", dir_data_process)
# clear_processing_files("g1|v4_g1", dir_data_process)
# clear_processing_files("g2|v4_g2", dir_data_process)
