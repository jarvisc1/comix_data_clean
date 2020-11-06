# CoMix data cleaning

Code for cleaning the data recieved for the CoMix contact survey.

# Run data cleaning. 

## For Mac
1. Open Rstudio
2. Go to the terminal in R studio
3. Type `Rscript run_cleaning.sh`

## For Windows

0. Add R to your path variable (see below)
1. Open Rstudio
2. Go to the terminal in R studio
3. Type `Rscript.exe run_cleaning.sh`

### Add R to your path variable

This only needs to be done once. Not for step 8 you need to put the path to your R\bin file. 

1. Select Start => Control Panel
2. Enter ‘environment’ in the search box and press RETURN
3. Click Edit the system environment variables
4. Click Advanced tab
5. Click Environment Variables…
6. Under User variables select PATH
7. Click Edit…
8. Add ;C:\Program Files\R\R-V.v.0\bin to end of Variable value, taking care to remove trailing spaces
9. Click OK
10. Click OK
11. Click OK

Check this has worked by going to powershell and typing `R.exe` a session of R should start. 

 # Cleaning steps
 
 1. Download all SPSS file from shared drive and save them as QS file locally.
 2. Check if country, wave, and panel variables are present.
 3. Reshape the data from wide to long.
 4. Rename variables.
 5. Combine data
 6. Clean existing variables
 7. Add new variables
 8. Split and serve data
 

