## Name: dm01_resave_spss_as_qs
## Description: Load all the remote spss files and save them as QS files locally
## Input file: Various spss files.sav
## Functions: save_spss_qs
## Output file: cnty_wkN_yyyymmdd_pN_wvN_1.qs

# Packages ----------------------------------------------------------------

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')
source('r/version_4/functions/save_spss_qs_v4.R')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("groups")) groups <- "G2"
if(length(args) == 1) groups <- args

# Open SPSS and save as QS ------------------------------------------------
groups <- "G2"
for(group in groups){
  print(paste0("Start: ", group))
  filenames <- readxl::read_excel('data/spss_files_eu.xlsx', sheet = group)
  filenames <- filenames[!is.na(filenames$spss_name),]
  
  spss_names <- paste0(filenames$spss_name, ".sav")
  r_names <- paste0(filenames$r_name, "_1.qs")
  current_country <- filenames$country
  # if (current_country == "sl") browser()
  # Note to optimize
  for(i in 1:length(r_names)){
    spss_file <- spss_names[i]
    print(paste0("Opening: ",spss_file))
    # if (r_names[i] == "sl_sr01_20210316_pA_wv01_1.qs") browser() 
    
    spss_path <- file.path(dir_data_spss, tolower(group), spss_file)
    df_ <- foreign::read.spss(spss_path)
    ## Convert to data.table
    dt_ <- data.table::as.data.table(df_)
    
    ## User written function: read spss file save as qs
    save_spss_qs(dt_, r_names[i], tolower(group), current_country[i])
    print(paste0("Saved: ", r_names[i]))
  }  
}


