## Name: dm01_resave_spss_as_qs
## Description: Save the dimension of the raw data for later comparisons
## Input file: cnty_wkN_yyyymmdd_pN_wvN_1.qs
## Functions: 
## Output file: dm01_data_dims.qs

# Packages ----------------------------------------------------------------
library(data.table)


# Source user written scripts ---------------------------------------------
source('r/00_setup_filepaths.r')


# Countries ---------------------------------------------------------------
country_codes <- c("UK", "NL", "BE", "NO")


# Create dimensions dataset -----------------------------------------------


dims <- list()

for(country in country_codes){
  print(paste0("Start: ", country))
  filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
  filenames <- filenames[!is.na(filenames$spss_name),]
  
  input_names <- paste0(filenames$r_name, "_1.qs")
  panel <- filenames$panel
  wave <- filenames$wave
  
  for(i in 1:length(input_names)){
    print(paste0("Opened: ", input_names[i]))
    
    input_path <- file.path(dir_data_process, input_names[i])
    dt <- qs::qread(input_path)
    
    print(paste0("Saved: ", input_names[i]))
    ## Record dimension
    dim_df <- data.table(country  = country,
                         panel = panel[i],
                         wave = wave[i],
                         r_name = input_names[i],
                         rows   =  nrow(dt),
                         cols   = ncol(dt))
    dims[[paste0(country,"_", input_names[i])]] <- dim_df
  }  
}

dims_dt <- rbindlist(dims)

qs::qsave(dims_dt, "data/tests/dm01_data_dims.qs")


