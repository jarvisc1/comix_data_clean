## Name: dm601sub_resave_spss_as_qs_v3
## Description: Load all the remote spss files and save them as QS files locally
##              For version 3 of the survey. 
## Input file: Various spss files.sav
## Functions: save_spss_qs
## Output file: cnty_wkN_yyyymmdd_pN_wvN_1.qs

# Packages ----------------------------------------------------------------
library(data.table)
# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')
source('./r/version_3/functions/survey_to_datatable_v3.R')

# Get arguments -----------------------------------------------------------

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country <- "UK"

# Open QS ------------------------------------------------


# There were some time periods where data was missing due to a survey error
# A second survey was done to try and fill in some of the gaps. 
## This data will need to be processed to be compatible with the other survey
## data
## T

dt <- qs::qread(file.path(dir_data_process, "uk_pepf_sub_2.qs"))

dt$wave <- -3

dt1 <- survey_to_datatable(dt)


dt1

qs::qsave(dt ,file.path(dir_data_process, "uk_pepf_sub_3.qs"))

