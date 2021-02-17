## Name: dm01_resave_spss_as_qs
## Description: Load all the remote spss files and save them as QS files locally
## Input file: Various spss files.sav
## Functions: save_spss_qs
## Output file: cnty_wkN_yyyymmdd_pN_wvN_1.qs

# Packages ----------------------------------------------------------------

# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')
source('r/version_5/functions/save_spss_qs_v5.R')

# Countries ---------------------------------------------------------------
# in case running for certain countries only
args <- commandArgs(trailingOnly=TRUE)
print(args)
if (!exists("groups")) groups <- "Group1"
if(length(args) == 1) groups <- args

# Open SPSS and save as QS ------------------------------------------------

for(group in groups){
  print(paste0("Start: ", group))
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = group)
  filenames <- filenames[!is.na(filenames$spss_name),]
  
  spss_names <- paste0(filenames$spss_name, ".sav")
  r_names <- paste0(filenames$r_name, "_1.qs")
  current_country <- filenames$country

  # Note to optimize
  for(i in 1:length(spss_names)){
    # for latest data.  
    #for(i in length(spss_names)){
    print(paste0("Opening: ",spss_names[i]))
    ## User written function: read sspss file save as qs
    save_spss_qs(spss_names[i], r_names[i], tolower(group), current_country[i])
    print(paste0("Saved: ", r_names[i]))
  }  
}


