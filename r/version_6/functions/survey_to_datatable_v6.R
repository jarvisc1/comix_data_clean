## Loop questions are questions such as what is the age for X?
## Where X may be each contact or household member or something like that.
## This function will separate the loop questions into different
## datasets called tables. If the loop question is called Q23 then it will
## produce table_q23.


## check_table_names run in the survey_to_datatable script. It
## checks whether the expected tables are in the data.


survey_to_datatable <- function(df, export_var_names = FALSE){
  empty_tables <- NULL
  ## Reshape to long format

  suppressWarnings(
      df <- melt(df,
               id.vars=c("respondent_id","wave", "panel", "country"),
               variable.factor=FALSE,
               value.factor=FALSE
       )
  )
  ## Sort the data by wave and then Id
  setorder(df, country, panel, wave, respondent_id)
  df_codes <- df
  ## Trim white space in values
  df[, value := trimws(value)]
  
  ## Replace missing value with NA
  df[value == "", value := NA]
  
  ## Create a data table of the "loop" variable questions
  ## Sapply creates a list of loop variables names by splitting where "_" occurs
  questions_lists <- sapply(unique(df[grepl("loop", variable), variable]),
                            strsplit, split="_"
  )
  
  # Lapply creates a data.table by looping over the sapply and puting the
  ## Different parts of the varibale names in different columns of the new
  ## data table
  
  questions_loop <- rbindlist(lapply(questions_lists,
                                     function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }),
                              fill=TRUE
  )
  
  ## Rename the loop variables combine into one column then remove NAs
  if (!("V5" %in% names(questions_loop))) questions_loop[, V5 := NA_character_]
  if (!("V6" %in% names(questions_loop))) questions_loop[, V6 := NA_character_]
  if (!("V7" %in% names(questions_loop))) questions_loop[, V7 := NA_character_]
  if (!("V8" %in% names(questions_loop))) questions_loop[, V8 := NA_character_]
  
  ## Rename the loop variables combine into one column then remove NAs
  
  questions_loop[, newname := paste(V2,V5,V6, V7, V8, sep = "_")]
  questions_loop[, "newname"] <- sapply(
    strsplit(questions_loop[, newname], "_"),
    function(x){
      paste0(x[which(x != "NA")], collapse="_")
    }
  )
  
  
  ## Create a tablename variable for each table
  questions_loop[, "tablename" := paste0("table_",V2)]
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
        country+respondent_id+panel+wave+V4 ~ newname, value.var="value"
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
      empty_tables <- c(empty_tables, q)
    }
  }
  
  ## Create a data table of the "loop" variable questions?
  
  assign("empty_tables", empty_tables)
  
  df <- dcast(df, country+respondent_id+panel+wave ~ variable)
  
  match_vars <- c("country", "respondent_id", "panel", "wave", "table_row")
  
  e <- environment()
  
  # Identify question tables and merge to create the final data.table
  tables <- grep("table_", names(e), value = T)
  tables <- grep("table_names|participant_table_questions|check_table_names", tables,
                 invert = TRUE, value = TRUE)
  table_names <- mget(unlist(tables))
  
  combine_dt <- Reduce(function(...) merge(..., by = match_vars, all = T), table_names)
  
  ## Remove all loop variables from the data as they're now replace by one for each loop
  set(df, j = grep("loop", names(df), value = TRUE), value = NULL)
  
  resp <- df[, list(country, respondent_id, panel, wave)]
  resp[,table_row := 0L]
  combine_dtr <- merge(combine_dt, resp, by = match_vars, all = T)
  
  df[, table_row := 0L]
  
  x_dt <- merge(df, combine_dt, by = match_vars, all = TRUE)
  
  
  return(x_dt)
}

