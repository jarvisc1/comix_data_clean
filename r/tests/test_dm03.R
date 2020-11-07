# dm_data_clean
library(data.table)


## Source relevant files
source('r/00_setup_filepaths.r')
source("r/functions/check_change_vars.R")
source("r/functions/survey_to_datatable.R")

# Setup input and output data and filepaths -------------------------------
country = "UK" # Can be moved out
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name),]
## This script loads _1.qs files and save them as _2.qs files
r_names <- filenames$r_name
r_name <- r_names[1]
print(paste0("Starting: ", r_name)) 
qs2_name <-  paste0(r_name, "_2.qs")
qs2_data <-  file.path(dir_data_process, qs2_name)
qs3_name <-  paste0(r_name, "_3.qs")
qs3_data <-  file.path(dir_data_process, qs3_name)
dt2 <- qs::qread(qs2_data)
dt3 <- qs::qread(qs3_data)

print(paste0("Opened: ", qs2_name))
print(paste0("Opened: ", qs3_name))

dim(dt2)
dim(dt3)




# Colomns lost and gained ------------------------------------------------------------


changed_vars <- check_change_vars(dt2, dt3, verbose = FALSE)
changed_vars$lost
changed_vars$gained


n_v_lost <- 0
n_v_gained <- 0
## All of the lost are due to scale questions being reduced to a single question. 
for ( i in unique(substring(changed_vars$lost, 1,3))){
  print(i)
  vars_lost <- length(grep(i, changed_vars$lost  , value = TRUE))
  vars_gained <- length(grep(i, changed_vars$gained, value = TRUE))
  print(vars_lost)
  print(vars_gained)
  n_v_lost <- n_v_lost + vars_lost
  n_v_gained <- n_v_gained + vars_gained
  
}

## Al the ones lost were due to scale :-)
## 398 I want this to be higher
print(paste0("Columns lost: ", n_v_lost))
## 26 I think I want this to be higher 
print(paste0("Columns gained: ", n_v_gained))

vars_gained


# Count the different types of variables ----------------------------------

## There are several different types of questions in the data
## loops = loops
## loop scale = loop_scale
## loop scale other question = loop_scale_oq
## scale = scale
## single question = sing

## Find the different types

check_var_types <- function(df) {
  
loops <- grep("q[1-9][0-9].*loop", names(df), value = TRUE)
loops <- grep("scale", loops, value = TRUE, invert = TRUE)
loop_scale <- grep("q[1-9][0-9].*loop_.*scale", names(df), value = TRUE)
loop_scale_oq <- grep("q[2-9][0-9].*loop.*_q[1-9][0-9].*scale", names(df), value = TRUE)

scales <- grep("q[1-9][0-9].*scale", names(df), value = TRUE)
scales <- grep("loop", scales, value = TRUE, invert = TRUE)
list(loops = loops, loop_scale = loop_scale, loop_scale_oq = loop_scale_oq, scales = scales)
}


vdt3 <- check_var_types(dt3)
vdt2 <- check_var_types(dt2)


# Determine which how single variables there are --------------------------


check_single_vars <- function(x1, x2){
  length(names(x1)) - (length(x2$loops) + length(x2$loop_scale) + length(x2$scales))
}

## 88
check_single_vars(dt2,vdt2)
## 222
check_single_vars(dt3,vdt3)

## Was TRUE
length(vdt2$loops) == length(vdt3$loops)
## TRUE
length(vdt2$loop_scale) == length(vdt3$loop_scale)
## TRUE
length(vdt2$loop_scale_oq) == length(vdt3$loop_scale_oq)

## We removed 372 I want it to be more after I've done these tests
(length(vdt2$scales) - length(vdt3$scales)) == 372
(length(vdt2$scales) - length(vdt3$scales))



# Get single var names ----------------------------------------------------

scale_vars2 <- unique(substr(vdt2$scales, 1,3))
scale_vars3 <- unique(substr(vdt3$scales, 1,3))
scale_vars2
scale_vars3

# Get the scale only variables
q21 <- grep("q21", names(dt2), value = TRUE)
q30 <- grep("q30", names(dt2), value = TRUE)
q35 <- grep("q35", names(dt2), value = TRUE)
q47 <- grep("q47", names(dt2), value = TRUE)
q21
q30
q35

q21 <- grep("q21", names(dt3), value = TRUE)
q30 <- grep("q30", names(dt3), value = TRUE)
q35 <- grep("q35", names(dt3), value = TRUE)
q47 <- grep("q47", names(dt3), value = TRUE)
q21
q30
q35


q23_scale <- grep("codes", q23_scale, value = TRUE, invert = TRUE)
q23_scale_n <- which(names(dt) %in% q23_scale)
q23_scale 

q23_n_names_n <- c(id_vars, q23_n_names_n, q23_scale_n)

q23_n_vars <- dt3[, ..q23_n_names_n]
head(q23_n_vars[!is.na(get(q23_n_names[1]))])





loop_vars <- unique(substr(vdt2$loops, 1,3))
loop_vars <- unique(substr(vdt3$loops, 1,3))
loop_vars


# Which variables have changed --------------------------------------------


# How many variables in dt3
## Should be equal
length(names(dt3)[!names(dt3) %in% c(loops, loop_scale, scales)])

## What are they called
names(dt3)[!names(dt3) %in% c(loops, loop_scale, scales)]


table(!names(dt3) %in% c(loops, loop_scale, scales))




##  I think there are more scale variables that could be removed at step 2
q72_names <- grep("q72", names(dt3), value = TRUE)

# identify id variables ---------------------------------------------------
dt3[,1:4] ## should be country, id, panel, wave
## Table row is contacts id where zero is participants
trow <- grep("table_row", names(dt), value = FALSE)
id_vars <- c(1:4, trow)

dt3[, ..id_vars]

## Question 23
nn <- "0" # For 2 digit put 11
pattern <- paste0("q23_loop_", nn,"_")
q23_n_names <- grep(pattern, names(dt3), value = TRUE)
q23_n_names <- grep("codes", q23_n_names, value = TRUE, invert = TRUE)
q23_n_names
q23_n_names_n <- which(names(dt) %in% q23_n_names)
q23_n_names_n <- c(id_vars, q23_n_names_n)

# Get the scale only variables
q23_scale <- grep("q23_loop", q23_names, value = TRUE, invert = TRUE)
q23_scale <- grep("codes", q23_scale, value = TRUE, invert = TRUE)
q23_scale_n <- which(names(dt) %in% q23_scale)
q23_scale 

q23_n_names_n <- c(id_vars, q23_n_names_n, q23_scale_n)

q23_n_vars <- dt3[, ..q23_n_names_n]
head(q23_n_vars[!is.na(get(q23_n_names[1]))])



## Only 222 non scale or loops vars


## Want to extract out the question numers



