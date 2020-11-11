country = "UK" # Can be moved out
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name),]
## This script loads _1.qs files and save them as _2.qs files
r_names <- filenames$r_name
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
r_name <- filenames$r_name[35]
=======
r_name <- filenames$r_name[1]
>>>>>>> 6313a80... Exploring changing the survey_to_datatable function
=======
r_name <- filenames$r_name[35]
>>>>>>> d2352f4... Update tests
=======
r_name <- filenames$r_name[35]
>>>>>>> 648b3d16d3bf0d9c04342c6b5d66d1cd8d7d779d
print(paste0("Starting: ", r_name)) 
qs2_name <-  paste0(r_name, "_2.qs")
qs2_data <-  file.path(dir_data_process, qs2_name)
qs3_name <-  paste0(r_name, "_3.qs")
qs3_data <-  file.path(dir_data_process, qs3_name)
qs4_name <-  paste0(r_name, "_4.qs")
qs4_data <-  file.path(dir_data_process, qs4_name)
dt2 <- qs::qread(qs2_data)
dt3 <- qs::qread(qs3_data)
dt4 <- qs::qread(qs4_data)



print(paste0("Opened: ", qs2_name))
print(paste0("Opened: ", qs3_name))
print(paste0("Opened: ", qs4_name))

dim(dt2)
dim(dt3)
dim(dt4)

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 648b3d16d3bf0d9c04342c6b5d66d1cd8d7d779d
grep("q75", names(dt2), value = TRUE)
grep("q80", names(dt2), value = TRUE)


table(dt2$q35_1_scale)
table(dt2$q35_2_scale)
table(dt2$q35_3_scale)
# Change in variables -----------------------------------------------------

source('r/functions/survey_to_datatable_temp.R')



<<<<<<< HEAD
=======
=======
grep("q75", names(dt2), value = TRUE)
grep("q80", names(dt2), value = TRUE)
>>>>>>> d2352f4... Update tests


table(dt2$q35_1_scale)
table(dt2$q35_2_scale)
table(dt2$q35_3_scale)
# Change in variables -----------------------------------------------------

source('r/functions/survey_to_datatable_temp.R')



<<<<<<< HEAD
# Change in variables -----------------------------------------------------
>>>>>>> 6313a80... Exploring changing the survey_to_datatable function
=======
>>>>>>> d2352f4... Update tests
=======
>>>>>>> 648b3d16d3bf0d9c04342c6b5d66d1cd8d7d779d

## This is really helpful to see how the variables change from spss
## to the R data.table. 




dim(dt2)
dim(dt3)


changed_vars <- check_change_vars(dt2, dt3, verbose = FALSE)

changed_vars <- check_change_vars(dt3, dt4, verbose = FALSE)
length(changed_vars$lost)
length(changed_vars$gained)


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

## Al the ones lostwere due to scale :-)
n_v_lost
n_v_gained


## Get a list of all of them.

## Find loops
qloops3 <- grep("loop", names(dt3), value = TRUE)


## Find loops scale q
qloops_scale_q3 <- grep("q[1-9][1-9]_loop_.*scale", names(dt3), value = TRUE)
## Find loops scale other q
qloops_scale_otherq3 <- grep("q[1-9][1-9]_loop.*_q[1-9][1-9].*scale", names(dt3), value = TRUE)

loop_scale_q <- unique(substring(qloops_scale_q3, 1,3))

loop_scale_otherq <- unique(substring(str_extract(qloops_scale_otherq3, "_q[1-9][1-9]"), 2,4))

## Two questions are for loop scale and don't have a questions or have a different question form the later one. 
loop_scale_q[!loop_scale_q %in% loop_scale_otherq]
# One related to the first and second question being differet
loop_scale_otherq[!loop_scale_otherq %in% loop_scale_q]

## Find scale loops with othe Q
qscales <- grep("loop", scales_loop, value = TRUE, invert = TRUE)
qscales <- grep("q[1-9][1-9].*scale", qscales, value = TRUE, invert = FALSE)
qscales
unique(substring(qloop_scale_names, 1,3))

## Other questions are all the ones left. 





table(qloop_scale_names2 %in% qloop_scale_names3)


## Also q72 which is later on. 

loop_vars <- unique(substr(loops, 1,3))
scale_vars <- unique(substr(scales, 1,3))
loop_vars
scale_vars

## Some are both. This is because they have a scale var,
## Which is then looped through the households. 
loop_vars[loop_vars %in% scale_vars]






substring()

q72_names <- grep("q72", names(dt3), value = TRUE)

q72_names
q31_names_1 <- grep("q31_loop_[1-9]_q31_1", names(dt), value = TRUE)


nn <- "0" # For 2 digit put 11
pattern <- paste0("q31_loop_", nn,"_")
q31_n_names <- grep(pattern, names(dt), value = TRUE)
q31_n_names <- grep("codes", q31_n_names, value = TRUE, invert = TRUE)
q31_n_names
q31_n_names_n <- which(names(dt) %in% q31_n_names)
q31_n_names_n <- c(id_vars, q31_n_names_n)

# Get the scale only variables
q31_scale <- grep("q31_loop", q31_names, value = TRUE, invert = TRUE)
q31_scale <- grep("codes", q31_scale, value = TRUE, invert = TRUE)
q31_scale_n <- which(names(dt) %in% q31_scale)
q31_scale 

q31_n_names_n <- c(id_vars, q31_n_names_n, q31_scale_n)

q31_n_vars <- dt[, ..q31_n_names_n]
head(q31_n_vars[!is.na(get(q31_n_names[1]))])




# Identify loop and scale variables ---------------------------------------

## Loop variables are for asking the same question for multiple household members
## Scale variables are for when the question has multiple answers, High, Medium, Low
## Loop variables are applited to different people. 
## The scale variable is asked of the same person
## They can be combined, a question can loop thorugh all household members with scales.

## There are not many loop scale variables. 

loops <- grep("loop", names(dt), value = TRUE)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
scales <- grep("scale", names(dt2), value = TRUE)
=======
scales <- grep("scale", names(dt), value = TRUE)
>>>>>>> 6313a80... Exploring changing the survey_to_datatable function
=======
scales <- grep("scale", names(dt2), value = TRUE)
>>>>>>> d2352f4... Update tests
=======
scales <- grep("scale", names(dt2), value = TRUE)
>>>>>>> 648b3d16d3bf0d9c04342c6b5d66d1cd8d7d779d
scales <- grep("loop", scales, value = TRUE, invert = TRUE)
loop_vars <- unique(substr(loops, 1,3))
scale_vars <- unique(substr(scales, 1,3))
loop_vars
scale_vars

## Some are both. This is because they have a scale var,
## Which is then looped through the households. 
loop_vars[loop_vars %in% scale_vars]


# Explore Question 39 -----------------------------------------------------



## Check on questions 39. 
## Did you 
## 1 = hhm_quarantine
## 2 = hhm_isolate
## 3 = hhm_limit_work
## 4 = hhm_limit_school

q39 <- grep("q39", names(dt), value = FALSE)
q39_names <- grep("q39", names(dt), value = TRUE)

# 182 variables
length(q39_names)

head(q39_names)
q39_names
# Format for scale loops
# qNN_loop_rowid_qNN_AN_scale
# where  rowid is tablerow, AN is the scale number (the answer)
# Format for scale only
# qNN_row__answer_scaleN




nn <- "3" # For 2 digit put 11
pattern <- paste0("q39_loop_", nn,"_")
q39_n_names <- grep(pattern, names(dt), value = TRUE)
q39_n_names
q39_n_names_n <- grep(pattern, names(dt), value = FALSE)
q39_n_names_n
q39_n_names_n <- c(id_vars, q39_n_names_n)
q39_n_vars <- dt[, ..q39_n_names_n]

head(q39_n_vars[!is.na(get(q39_n_names[1]))])

# Get the scale only variables
q39_scale <- grep("q39_loop", q39_names, value = TRUE, invert = TRUE)
q39_scale_n <- which(names(dt) %in% q39_scale)
q39_scale 

q39_n_names_n <- c(id_vars, q39_n_names_n, q39_scale_n)

q39_n_vars <- dt[, ..q39_n_names_n]

# The single scale variable replaces the loop variable can be removed.
head(q39_n_vars[!is.na(get(q39_n_names[1]))])


# Check for q31 -----------------------------------------------------------

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
grep("q76", names(dt2), value = TRUE)
=======
>>>>>>> 6313a80... Exploring changing the survey_to_datatable function
=======
grep("q76", names(dt2), value = TRUE)
>>>>>>> d2352f4... Update tests
=======
grep("q76", names(dt2), value = TRUE)
>>>>>>> 648b3d16d3bf0d9c04342c6b5d66d1cd8d7d779d
q31_names <- grep("q31", names(dt), value = TRUE)

q31_names_1 <- grep("q31_loop_[1-9]_q31_1", names(dt), value = TRUE)


nn <- "0" # For 2 digit put 11
pattern <- paste0("q31_loop_", nn,"_")
q31_n_names <- grep(pattern, names(dt), value = TRUE)
q31_n_names <- grep("codes", q31_n_names, value = TRUE, invert = TRUE)
q31_n_names
q31_n_names_n <- which(names(dt) %in% q31_n_names)
q31_n_names_n <- c(id_vars, q31_n_names_n)

# Get the scale only variables
q31_scale <- grep("q31_loop", q31_names, value = TRUE, invert = TRUE)
q31_scale <- grep("codes", q31_scale, value = TRUE, invert = TRUE)
q31_scale_n <- which(names(dt) %in% q31_scale)
q31_scale 

q31_n_names_n <- c(id_vars, q31_n_names_n, q31_scale_n)

q31_n_vars <- dt[, ..q31_n_names_n]
head(q31_n_vars[!is.na(get(q31_n_names[1]))])




# Check loop only variables -----------------------------------------------
loop_vars[!loop_vars %in% scale_vars]

q23_names <- grep("q23", names(dt), value = TRUE)
q42_names <- grep("q42", names(dt), value = TRUE)
q23_names
q42_names
q23_names_1 <- grep("q23_loop_[1-9]_q23_1", names(dt), value = TRUE)


nn <- "0" # For 2 digit put 11
pattern <- paste0("q23_loop_", nn,"_")
q23_n_names <- grep(pattern, names(dt), value = TRUE)
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

q23_n_vars <- dt[, ..q23_n_names_n]
head(q23_n_vars[!is.na(get(q23_n_names[1]))])




































## Exploring certain variables
grep("q21", changed_vars$lost  , value = TRUE))
grep("q21", changed_vars$gained, value = TRUE)
grep("q29", changed_vars$lost, value = TRUE)
grep("q29", changed_vars$gained, value = TRUE)

grep("q28", changed_vars$lost  , value = TRUE)
grep("q28", changed_vars$gained, value = TRUE)
grep("q66", changed_vars$lost  , value = TRUE)
grep("q66", changed_vars$gained, value = TRUE)




changed_vars <- check_change_vars(dt3, dt4, verbose = FALSE)

length(changed_vars$lost)
length(changed_vars$gained)

changed_vars$lost[1:20]
changed_vars$gained
grep("q21", changed_vars$lost  , value = TRUE)
grep("q21", changed_vars$gained, value = TRUE)
grep("q28", changed_vars$lost  , value = TRUE)
grep("q28", changed_vars$gained, value = TRUE)
grep("q66", changed_vars$lost  , value = TRUE)
grep("q66", changed_vars$gained, value = TRUE)


# Read in data ------------------------------------------------------------
dt2 <- dt

dt2 <- survey_to_datatable(dt)

table(names(dt1) %in% names(dt2))
dim(dt1)
dim(dt2)

table(dt2$table_row)

