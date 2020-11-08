library(data.table)
source('r/functions/survey_to_datatable_temp.R')
source('r/functions/survey_to_datatable.R')
source('r/functions/check_table_names.R')
source('r/00_setup_filepaths.r')


# create dummy data -------------------------------------------------------


test_data <- data.table(country = "uk", 
                        panel = "A",
                        wave = 1,
                        respondent_id = 101,
                        q99 = "q99_single",
                        ## Scale question
                        q100_0_scale = "q100_0",
                        q100_1_scale = "q100_1",
                        q100_2_scale = "q100_2",
                        q100_3_scale = "q100_3",
                        ## Scale question multiple
                        q101_0_scale_1 = "q101_0_1",
                        q101_0_scale_2 = "q101_0_2",
                        q101_0_scale_3 = "q101_0_3",
                        q101_1_scale_1 = "q101_1_1",
                        q101_1_scale_2 = "q101_1_2",
                        q101_1_scale_3 = "q101_1_3",
                        q101_2_scale_1 = "q101_2_1",
                        q101_2_scale_2 = "q101_2_2",
                        q101_2_scale_3 = "q101_2_3",
                        ## Loop scale no second question
                        q102_loop_0_scale_1 = "q102_0_1",
                        q102_loop_0_scale_2 = "q102_0_2",
                        q102_loop_0_scale_3 = "q102_0_3",
                        q102_loop_1_scale_1 = "q102_1_1",
                        q102_loop_1_scale_2 = "q102_1_2",
                        q102_loop_1_scale_3 = "q102_1_3",
                        q102_loop_2_scale_1 = "q102_2_1",
                        q102_loop_2_scale_2 = "q102_2_2",
                        q102_loop_2_scale_3 = "q102_2_3",
                        # Loop scale same question
                        q103_loop_0_q103_scale_1 = "q103_0_1",
                        q103_loop_0_q103_scale_2 = "q103_0_2",
                        q103_loop_0_q103_scale_3 = "q103_0_3",
                        q103_loop_1_q103_scale_1 = "q103_1_1",
                        q103_loop_1_q103_scale_2 = "q103_1_2",
                        q103_loop_1_q103_scale_3 = "q103_1_3",
                        q103_loop_2_q103_scale_1 = "q103_2_1",
                        q103_loop_2_q103_scale_2 = "q103_2_2",
                        q103_loop_2_q103_scale_3 = "q103_2_3",
                        # Loop scale different question
                        q103_loop_0_q104_scale_1 = "q103_q104_0_1",
                        q103_loop_0_q104_scale_2 = "q103_q104_0_2",
                        q103_loop_0_q104_scale_3 = "q103_q104_0_3",
                        q103_loop_1_q104_scale_1 = "q103_q104_1_1",
                        q103_loop_1_q104_scale_2 = "q103_q104_1_2",
                        q103_loop_1_q104_scale_3 = "q103_q104_1_3",
                        q103_loop_2_q104_scale_1 = "q103_q104_2_1",
                        q103_loop_2_q104_scale_2 = "q103_q104_2_2",
                        q103_loop_2_q104_scale_3 = "q103_q104_2_3",
                        
                        ## Loop question no second question
                        q105_loop_0 = "q105_0",
                        q105_loop_1 = "q105_1",
                        q105_loop_2 = "q105_2",
                        ## Loop question same question
                        q106_loop_0_q106 = "q106_0",
                        q106_loop_1_q106 = "q106_1",
                        q106_loop_2_q106 = "q106_2",
                        ## Loop question diff Q
                        q106_loop_0_q107 = "q106_q107_0",
                        q106_loop_1_q107 = "q106_q107_1",
                        q106_loop_2_q107 = "q106_q107_2",
                        ## Loop oother
                        q108_loop_0_q108_filter = "q108_0_q108_filter",
                        q108_loop_1_q108_filter = "q108_1_q108_filter",
                        q108_loop_2_q108_filter = "q108_2_q108_filter",
                        region = "Hello",
                        missing = "",
                        extra_white_space = "        H ello      "
                        
)



# Run code ----------------------------------------------------------------



#debugonce("survey_to_datatable_temp")

x1 <- survey_to_datatable_temp(test_data)
x2 <- survey_to_datatable(test_data)
x2
dim(test_data)
names(x1)
names(x2)

place <- grep("q100", names(x1))
x1[, ..place]
place <- grep("q100", names(x2))
x2[, ..place]

place <- grep("q101", names(x1))
x1[, ..place]
place <- grep("q101", names(x2))
x2[, ..place]

place <- grep("q102", names(x1))
x1[, ..place]
place <- grep("q102", names(x2))
x2[, ..place]

place <- grep("q103", names(x1))
x1[, ..place]
place <- grep("q103", names(x2))
x2[, ..place]

place <- grep("q104", names(x1))
x1[, ..place]
place <- grep("q104", names(x2))
x2[, ..place]

place <- grep("q105", names(x1))
x1[, ..place]
place <- grep("q105", names(x2))
x2[, ..place]

x2[, n1:n2]

x2[, 55:63]


















# First attempt

country = "UK" # Can be moved out
filenames <- readxl::read_excel('data/spss_files.xlsx', sheet = country)
filenames <- filenames[!is.na(filenames$spss_name),]
## This script loads _1.qs files and save them as _2.qs files
r_names <- filenames$r_name
r_name <- filenames$r_name[1]
print(paste0("Starting: ", r_name)) 
qs2_name <-  paste0(r_name, "_2.qs")
qs2_data <-  file.path(dir_data_process, qs2_name)
dt2 <- qs::qread(qs2_data)


#debugonce("survey_to_datatable_temp")
xx1 <- survey_to_datatable_temp(dt2)
xx2 <- survey_to_datatable(dt2)

max(xx1$table_row)
max(xx2$table_row)

dim(xx1)
dim(xx2)
rowid <- grep("table_row", names(xx1))
place <- grep("q53$", names(xx1))
place <- c(1:5, rowid,  place)
xx1[respondent_id == 1, ..place]
rowid <- grep("table_row", names(xx2))
place <- grep("q53$", names(xx2))
place <- c(1:5, rowid,  place)
xx2[respondent_id == 1, ..place]




print(paste0("Opened: ", qs2_name))

dim(dt2)

grep("q75", names(dt2), value = TRUE)
grep("q80", names(dt2), value = TRUE)


