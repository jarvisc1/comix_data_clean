## Check the functions. Not sure if there is much needed to check if the variables have been added. 


## This needs to be updated using testthat or something like that.

# Create dummy data to check function -------------------------------------

source('r/functions/check_cnty_panel_wave.R')
## Fail
other_country <- data.frame(qcountry = c("be"))
country_checker(other_country, "uk")

# Should treat missing as other
na_country <- data.frame(country = NA)
country_checker(na_country, "uk")

## Should change to UK
empty_country <- data.table(panel = NA)
country_checker(empty_country, "uk")

# Creates country variable
name1 <- data.table(qcountry = "uk")
country_checker(name1, "uk")

multi_country <- data.frame(qcountry = c("uk", "be", NA))
country_checker(multi_country, "uk")

other_panel <- data.frame(panel = "B")
panel_checker(  other_panel, "A")

missing_panel <- data.frame(panel = NA)
panel_checker(  missing_panel, "A")
missing_panel <- data.frame(gpanel = NA)
panel_checker(  missing_panel, "A")

no_panel <- data.frame(name = 1)
panel_checker(  missing_panel, "A")

multi_panel <- data.frame(panel = c("A", "B"))
panel_checker(  multi_panel, "A")

source('r/functions/check_cnty_panel_wave.R')
other_wave <- data.frame(wave = 1)
wave_checker(  other_wave, 3)
missing_wave <- data.frame(wave = NA)
wave_checker(  missing_wave, 3)

missing_wave <- data.frame(wave = c(NA, 1:4))
wave_checker(  missing_wave, 3)

name_wave <- data.frame(pwave = 3)
wave_checker(  name_wave, 3)
name_wave1 <- data.frame(pwave = "Wave 3")
wave_checker(  name_wave1, 3)


