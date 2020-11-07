library(data.table)


## Source relevant files
source('r/setup_filepaths.r')
source("r/functions/check_change_vars.R")
source("r/functions/survey_to_datatable.R")

test_data <- data.table(country = "uk", 
                        panel = "A",
                        wave = 1,
                        respondent_id = 101,
                        ## Scale question
                        q101_0_scale = 1,
                        q101_1_scale = 4,
                        q101_2_scale = 8,
                        q101_3_scale = 10,
                        ## Loop through household members with a scale
                        q102_loop_0_scale_1 = 1,
                        q102_loop_0_scale_2 = 2,
                        q102_loop_0_scale_3 = 3,
                        q102_loop_1_scale_1 = 4,
                        q102_loop_1_scale_2 = 5,
                        q102_loop_1_scale_3 = 6,
                        q102_loop_2_scale_1 = 7,
                        q102_loop_2_scale_2 = 8,
                        q102_loop_2_scale_3 = 9,
                        q102_loop_3_scale_1 = 10,
                        q102_loop_3_scale_2 = 11,
                        q102_loop_3_scale_3 = 12,
                        
                        ## Loop question
                        q103_loop_0_q103 = 1,
                        q103_loop_1_q103 = 4,
                        q103_loop_2_q103 = 8,
                        q103_loop_3_q103 = 10,
                        ## Loop question diff Q
                        q103_loop_0_q104 = 1,
                        q103_loop_1_q104 = 4,
                        q103_loop_2_q104 = 8,
                        q103_loop_3_q104 = 10,
                        region = "Hello",
                        missing = "",
                        extra_white_space = "        H ello      "
                        
                        )

test_outcome <- survey_to_datatable(test_data)

## country, panel, id, and wave are consistent,
## There are four rows, one for participant and three for households

## Q101 becomes a single question
test_outcome

test_outcome[, .(country, 
                 respondent_id ,
                 panel ,
                 wave ,
                 q102_loop_1_scale_1 ,
                 q102_loop_1_scale_2, 
                 q102_loop_1_scale_3,
                 scale_1, 
                 scale_2,
                 scale_3)]



## First part of the code
skip_loop_questions = FALSE

df <- test_data

## First 3 steps
df <- melt(
  df,
  id.vars=c("respondent_id","wave", "panel", "country"),
  variable.factor=FALSE,
  value.factor=FALSE
)


## Sort the data by wave and then Id
setorder(df, country, panel, wave, respondent_id)
df
df_codes <- df
## Trim white space in values
df[, value := trimws(value)]
df

## Replace missing value with NA
df[value == "", value := NA]
df



# Sorting loop questions --------------------------------------------------

if (skip_loop_questions == FALSE) {
  ## Create a data table of the "loop" variable questions
  ## Sapply creates a list of loop variables names by splitting where "_" occurs
  questions_lists <- sapply(
    unique(df[grepl("loop", variable), variable]),
    strsplit, split="_"
  )
  
  
  # Lapply creates a data.table by looping over the sapply and puting the
  ## Different parts of the varibale names in different columns of the new
  ## data table
  questions_loop <- rbindlist(
    lapply(questions_lists,
           function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
    ),
    fill=TRUE
  )
  
  
  ## Rename the loop variables combine into one column then remove NAs
  if (!("V5" %in% names(questions_loop))) questions_loop[, V5 := NA_character_]
  if (!("V6" %in% names(questions_loop))) questions_loop[, V6 := NA_character_]
  if (!("V7" %in% names(questions_loop))) questions_loop[, V7 := NA_character_]
  if (!("V8" %in% names(questions_loop))) questions_loop[, V8 := NA_character_]
  
  questions_loop[, newname := paste0(V5,"_",V6,"_",V7,"_",V8)]
  questions_loop[, "newname"] <- sapply(
    strsplit(questions_loop[, newname], "_"),
    function(x){
      paste0(x[which(x != "NA")], collapse="_")
    }
  )
  
  ## Create a tablename variable for each table
  questions_loop[, "tablename" := paste0("table_",V2)]
  remove_q52 <- grep("q53", questions_loop$newname, invert = TRUE)
  questions_loop <- questions_loop[remove_q52]
  remove_q60 <- grep("q60", questions_loop$newname, invert = TRUE)
  questions_loop <- questions_loop[remove_q60]
  
  
  # ## Create a separate table for for loop question
  for(q in unique(questions_loop[, V2])){
    
    ## Pick data for relevant question
    current_q <- questions_loop[V2 == q]
    
    ## Merge on dataframe information for q
    current_q <- merge(current_q, df, by.x="V1", by.y="variable")
    
    ## Remove empty rows
    current_q <- current_q[!is.na(value)]
    
    ## Re-create table to be wide structure instead of very long
    if(nrow(current_q) > 0){
      ## Reshape to wide x ~ y where x will be rows, y columns
      
      current_q <- dcast(
        current_q,
        country+respondent_id+panel+wave+V4 ~ V5+V6+V7+V8, value.var="value"
      )
      
      ## Order table by respondent_id wave and the row (V4)
      class(current_q$V4) <- "integer"
      setorder(current_q, country, respondent_id, panel,  wave, V4)
      colnames(current_q)[which(colnames(current_q) == "V4")] <- "table_row"
      
      ## Remove NA's in column names
      colnames(current_q) <- sapply(
        strsplit(colnames(current_q), "_"),
        function(x){
          paste0(x[which(x != "NA")], collapse="_")
        }
      )
      ## Assign current_q to object table_q
      assign(paste0("table_",q), current_q)
    } else {
      message(paste0("table for ", q, " is empty"))
      # store empty_tables
      empty_tables <- c(empty_tables, q)
      
    }
  }
}