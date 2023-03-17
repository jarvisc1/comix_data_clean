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
source('./r/version_3/functions/standardise_names_v3.R')


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

pe_sub <- qs::qread(file.path(dir_data_process, "uk_pe_sub_1.qs"))
pf_sub <- qs::qread(file.path(dir_data_process, "uk_pf_sub_1.qs"))
id_err <- qs::qread(file.path(dir_data_process, "uk_pepf_sub_id_errors.qs"))



dt <- rbindlist(list(pe_sub, pf_sub), use.names = TRUE)

dt[, ipsos_id := respondent_id]
dt[, respondent_id := respondent_id + 100000*as.numeric(factor(panel, LETTERS))]
dt[, country := "UK"]
dt

# Standardise names -------------------------------------------------------
names(dt) <- standardise_names(names(dt))


qs::qsave(dt ,file.path(dir_data_process, "uk_pepf_sub_2.qs"))

