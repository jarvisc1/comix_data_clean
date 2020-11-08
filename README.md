# CoMix data cleaning

Code for cleaning the data recieved for the CoMix contact survey.

## To do:
1. Parrallelise code.
2. Remove overall cleaning and allow for a single dataset to be updated. 

# Folder structure

Folders

* `r` - for R scripts
* `r/functions` - store user written functions for the cleaning
* `data` - for the datasets
* `data/processing` - for interim cleaning datasets
* `data/clean` - for cleaned datasets
* `codebooks` - Codebooks used for data cleaning
* `admin` - For information about the cleaning

# Cleaning steps
 
1. Download all SPSS files from shared drive and save them as QS file locally.
2. Check if country, wave, and panel variables are present.
3. Reshape the data from wide to long.
4. Rename variables.
5. Combine data
6. Clean existing variables
7. Add new variables
8. Split and serve data
 
# Run all data cleaning. 

## For Mac
1. Open Rstudio
2. Go to the terminal in Rstudio
3. Type `sh run_cleaning.sh`

## For Windows

0. Add R to your path variable (see below)
1. Open Rstudio
2. Go to the terminal in R studio
3. Type `sh run_cleaning.sh`

### Add R to your path variable

This only needs to be done once. Note for step 8 you need to put the path to your R\bin file. 

1. Select Start => Control Panel
2. Enter ‘environment’ in the search box and press RETURN
3. Click Edit the system environment variables
4. Click Advanced tab
5. Click Environment Variables…
6. Under User variables select PATH
7. Click Edit…
8. Add C:\Program Files\R\R-V.v.0\bin to end of Variable value, taking care to remove trailing spaces
9. Click OK
10. Click OK
11. Click OK

Check this has worked by going to powershell and typing `R.exe` a session of R should start. 

# Actions

The actions that you may need for cleaning the data fall into the following. 

**[1. Add a new dataset/ replace an old dataset with a new version](#add-new-or-replace-old-data)<br />**
&nbsp;[a. Update a single country with the latest data](#single-country)<br />
&nbsp;[b. Update multiple countries with the latest data](#multiple-countries)<br />
**[2. Reclean old data](#reclean-old-data)<br />**
&nbsp;[a. Reclean a single dataset](#single-dataset)<br />
&nbsp;[b. Reclean all datasets for a single country](#all-datasets-single-country)<br />
&nbsp;[c. Reclean all datsets for all countries](#all-datasets-all-countries)<br />
**[3. Combining data](#combine-data)<br />**
&nbsp;[a. Combining all data for a single country](#combine-single-country)<br />
&nbsp;[b. Combining all data for all countries](#combine-all-countries)<br />
**[4. Add new variables](#add-new-variables)<br />**
&nbsp;[a. New variables created in the raw data](#new-survey-variable)<br />
&nbsp;[b. New user defined variable](#new-analysis-variable)<br />
**[5. Add checks](#add-checks)<br />**
**[6. Sharing data](#share-data)<br />**
&nbsp;[a. Create summary datsets for sharing](#summary-data)<br />
&nbsp;[b. Sharing individual level data](#individual-level-data)<br />



# Add new or replace old data
## Single country

### 1. SPSS file

The SPSS data should be stored on the LSHTM shared drive.

SPSS files are recieved via email as zipped files. Save the files on the LSHTM shared drive folder at X.
Extract the file, this will require a password. Check with Chris, Amy, or Kerry for file passwords
Then save the extracted spss file in data/spss/country_code. The country_codes are

Country | Country_code | 
--- | --- | 
United Kingdom | UK | 
Norway | NO | 
Netherlands | NL |
Belgium | BE |
Add country | Add country_code|

### 2. Update spreadsheet

1. Open the spreadsheet in data/spss_files.xlsx
2. Go to the relevant country tab 
3. Add the information for SPSS file to the bottom of the sheet
4. Fill in the Panel, Wave, date recieved, week, spss filename, and drag down the formula for the R file_name. 

### 3. Save SPSS as RDS

**We could have separate scripts that run for just one file or one timepoint at a time**

1. Open `dm01_resave_spss_as_manual.rds` 
2. Update the country code and then run the first section of the code to save the RDS file.

For multiple countries there is further code which can loop through the different parts. 

The SPSS files are loaded and then turned into RDS files. 

The file naming convention for the RDS files. 

cnty_wkN_yyyymmdd_pN_wvN_extranotes.RDS

* Cnty = country code uk, nl, be
* wk = survey week
* yyyymmdd = date that file was sent
* pN =  panel
* wv = wave number
* extranotes = it could be interim data, or for updates of the data.

## Multiple countries

**Need to update**
For multiple countries repeat steps 1 and 2 from the single country section. 
Then run the for loop to run for multipl countries in **

# Reclean old data

* Should these be a bash script where you put in the country code and then it will compile and pull the latest as long as you've updated the spreadsheet.
* Not a fun task but important to check what data we recieve and that it is present. We can alternate this task and make sure we're all recieving the data.

## Single dataset

## All datasets single country
* Need to be able to select for multiple countries. 
* A bash script where you can pick multiple country code would be great. 

## All datasets all countries

* This is our reproducible analysis. Run from begining to end and output all the data. 


# Combine data

* I think combining data should be different from cleaning. 
* Might want to split sections into combining all data from scratch and just adding a new dataset onto an old one. 
* Do we want different datasets per country or one for each country?
## Combine single country
# Combine all countries

# Add new variables

## New survey variable
* Detail where the change was made what question as well
* Add to code
* Update codebook

## New analysis variable

* should be done at the combined data level
* Specify the script where the variable is created
* Update codebook
* rerun for all combined data

# Add checks

* Use the validator package
* do we have a check folder?
* At what point should the check takes place?
* checks on raw data
* checks on coding and created variables
* sanity checks

# Share data

* Need some sort of dates on the files.
* File naming convention
* Need to decide what level of summary data would we want? Bootstrapped mean is analysis but mean summaries aren't really good enough here.
* Calculating R is also not for data cleaning

## Individual level data
* I think we should create one combined dataset for participants, households, contacts. 
* Then we can slice it for each country and zip and serve.
* Can we zip the file and password protect with R and send in an email. ? Surely this is possible and worthwhile as will be doing for lots of countries. 



