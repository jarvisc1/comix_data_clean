## Name: dm600sub_resave_spss_as_qs_v3
## Description: Load all the remote spss files and save them as QS files locally
##              For version 3 of the survey. 
## Input file: Various spss files.sav
## Functions: save_spss_qs
## Output file: cnty_wkN_yyyymmdd_pN_wvN_1.qs

# Packages ----------------------------------------------------------------

# Source user written scripts ---------------------------------------------
source('./r/00_setup_filepaths.r')
source('./r/version_3/functions/standardise_names_v3.R')


# Get arguments -----------------------------------------------------------

# Countries ---------------------------------------------------------------
# in case running for certain countries only
country <- "UK"

# Open SPSS and save as QS ------------------------------------------------


# There were some time periods where data was missing due to a survey error
# A second survey was done to try and fill in some of the gaps. 
## This data will need to be processed to be compatible with the other survey
## data
## T


spss_path <- file.path(dir_data_spss, "uk")

pe_sub_file <- file.path(spss_path, "21-037558_PanelE_SubSurvey_Final_ICUO.sav")
pf_sub_file <- file.path(spss_path, "21-037554_PanelF_SubSurvey_Final_ICUO.sav")
id_err_file <- file.path(spss_path, "20210627_home_contact_error_f18toe23.csv")

pe_sub <- as.data.table(foreign::read.spss(pe_sub_file))
pf_sub <- as.data.table(foreign::read.spss(pf_sub_file))
id_err <- fread(id_err_file)

names(pe_sub) <- tolower(names(pe_sub))
names(pf_sub) <- tolower(names(pf_sub))


# Save the data. ----------------------------------------------------------
qs::qsave(pe_sub ,file.path(dir_data_process, "uk_pe_sub_1.qs"))
qs::qsave(pf_sub ,file.path(dir_data_process, "uk_pf_sub_1.qs"))
qs::qsave(id_err ,file.path(dir_data_process, "uk_pepf_sub_id_errors.qs"))

