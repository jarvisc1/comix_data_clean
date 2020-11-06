## Name: dm01_resave_spss_as_qs
## Description: Load all the remote spss files and save them as QS files locally
## Input file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs
## Functions: save_spss_qs
## Output file: cnty_wkN_yyyymmdd_pN_wvN_XX.qs


# Packages ----------------------------------------------------------------

# Source user written scripts ---------------------------------------------
source('r/setup_filepaths.r')
source('r/functions/save_spss_qs.R')

# Countries ---------------------------------------------------------------
country_codes <- c("UK", "NL", "BE", "NO")

# Open SPSS and save as QS ------------------------------------------------

for(country in country_codes){
  print(paste0("Start: ", country))
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
  filenames <- filenames[!is.na(filenames$spss_name),]
  
  spss_names <- paste0(filenames$spss_name, ".sav")
  r_names <- paste0(filenames$r_name, "_1.qs")
  
  for(i in 1:length(spss_names)){
    print(paste0("Opened: ",spss_names[i]))
    ## User written function: read sspss file save as qs
    save_spss_qs(spss_names[i], r_names[i])
    print(paste0("Saved: ", r_names[i]))
  }  
}

