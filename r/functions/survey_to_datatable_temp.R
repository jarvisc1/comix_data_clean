

## Loop questions are questions such as what is the age for X?
## Where X may be each contact or household member or something like that.
## This function will seperate the loop questions into different
## datasets called tables. If the loop question is called Q23 then it will
## produce table_q23.


survey_to_datatable <- function(df, export_var_names = FALSE, skip_loop_questions = FALSE){
  empty_tables <- NULL
  
  ## Reshape to long format
  df <- melt(
    df,
    id.vars=c("respondent_id","wave", "panel", "country"),
    variable.factor=FALSE,
    value.factor=FALSE
  )

  ## Sort the data by wave and then Id
  setorder(df, country, panel, wave, respondent_id)
  df_codes <- df
  ## Trim white space in values
  df[, value := trimws(value)]

  ## Replace missing value with NA
  df[value == "", value := NA]

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
  ## Create a data table of the "loop" variable questions?

  ## Sapply creates a list of loop variables names by splitting where "_" occurs
  questions_list_scale <- sapply(
    unique(df[grepl("scale", variable) &
                !grepl("loop", variable), variable]),
    strsplit, split="_"
  )


  ## Lapply creates a data.table by looping over the sapply and puting the
  ## Different parts of the varibale names in different columns of the new
  ## data table
  questions_scale <- rbindlist(
    lapply(questions_list_scale,
           function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
    ),
    fill=TRUE
  )

  if (!("V5" %in% names(questions_scale))) {
    questions_scale[, V5 := NA]
  }

  # q75 and q76 are tables but act more like scales
  participant_table_questions <- grep("q75|q76",  questions_scale$V1, value = TRUE)
  
  ## This could be more restrictive as UK and other countries may diverge.
  if (as.character(df$panel[1]) %in% c("A", "B", "C", "D")) {
    participant_table_questions <- grep("q75|q76",  questions_scale$V1, value = TRUE)
  } else if ((as.character(df$panel[1]) %in% c("E", "F"))) {
    participant_table_questions <- grep("q79|q80|q81",  questions_scale$V1, value = TRUE)
  }
  
  
  
  # set table row to 0 as it is asked of the participant
  questions_scale[V1 %in% participant_table_questions, V3 :=  0L]
  questions_scale[V1 %in% participant_table_questions, V2 := V1]




  questions_scale[, newname := fifelse(is.na(V5),
                                       paste0(V2),
                                       paste0(V2,"_",V5))
  ]
  questions_scale <- questions_scale[! newname %in% c("q35", "q36", "q37", "q38",
                                                      "q52", "q55", "Q60")]
  
  questions_scale[, "tablename" := paste0("table_",V2)]
  
  for(q in unique(questions_scale[, V2])){
    current_q <- questions_scale[V2 == q]
    current_q <- merge(current_q, df, by.x="V1", by.y="variable")

    ## Remove empty rows
    current_q <- current_q[!is.na(value)]

    ## Re-create table
    if(nrow(current_q) > 0){

      current_q <- dcast(current_q, country+respondent_id+panel+wave+V3 ~ newname, value.var="value")

      ## Order table in correct rows
      class(current_q$V3) <- "integer"
      setorder(current_q, country, respondent_id, panel, wave, V3)
      colnames(current_q)[which(colnames(current_q) == "V3")] <- "table_row"
      ## Remove NA's in column names
      colnames(current_q) <- sapply(
        strsplit(colnames(current_q), "_"),
        function(x){
          paste0(x[which(x != "NA")], collapse="_")
        }
      )
      #assign in global environment

      assign(paste0("table_",q), current_q)
    } else {
      message(paste0("table for ", q, " is empty"))
      empty_tables <- c(empty_tables, q)
    }
  }

  # Contact flags
  if (as.character(df$panel[1]) %in% c("A", "B", "C", "D")) {
    contact_flags <- paste0("contact", 1:100)
  } else if ((as.character(df$panel[1]) %in% c("E", "F"))) {
    contact_flags <- paste0("contact", c(900:max(table_q66$table_row)))
  }
  table_contact_flag <- df[variable %in% contact_flags]
  table_contact_flag <- table_contact_flag[!is.na(value) & value != "0"]
  setnames(table_contact_flag, old = "value", new = "contact_name_flag")
  # Add 20 to table_row because contact table rows begin here
  table_contact_flag <-
    table_contact_flag[, table_row := as.numeric(sub("contact", "", variable)) + 20]
  table_contact_flag$variable <- NULL
  table_contact_flag[, contact_name_flag := gsub("‘|’", "", contact_name_flag)]

  # CHILD SURVEY TABLES
  # ##########################

  if (sum(grepl("hhcomp", unique(df$variable))) > 0) {
    # HHCOMPCONFIRM_1

    # HHCOMPREMOVE_1

    if (as.character(df$panel[1]) %in% c("A", "B", "C", "D")) {
      hhcomp_remove_colnames <-  paste0("hhcompremove_", c(1:11,150:200))
    } else if ((as.character(df$panel[1]) %in% c("E", "F"))) {
      hhcomp_remove_colnames <- df$variable[grepl("hhcompremove_[0-9]+", df$variable)]
    }
    
    table_hhcomp_remove <- df[variable %in% hhcomp_remove_colnames]
    table_hhcomp_remove <- table_hhcomp_remove[!is.na(value) & value != "0"]
    setnames(table_hhcomp_remove, old = "value", new = "hhcomp_remove")
    table_hhcomp_remove <-
      table_hhcomp_remove[, table_row := as.numeric(sub("hhcompremove_", "", variable))]
    table_hhcomp_remove <- table_hhcomp_remove[hhcomp_remove == "Yes"]
    table_hhcomp_remove$variable <- NULL
    df <- df[!(variable %in% hhcomp_remove_colnames)]


    # HHCOMPADD_1_scale
    # ###################

    # IPSOS identifies added hh members as 150 - 156
    if (as.character(df$panel[1]) %in% c("A", "B", "C", "D")) {
      hhcomp_add_colnames <-  paste0("hhcompadd_", c(150:156), "_scale")
    } else if ((as.character(df$panel[1]) %in% c("E", "F"))) {
      hhcomp_add_colnames <-  df$variable[grepl("hhcompadd_[0-9]+", df$variable)]
    }
    table_hhcomp_add <- df[variable %in% hhcomp_add_colnames]
    table_hhcomp_add <- table_hhcomp_add[!is.na(value) & value != "0"]
    setnames(table_hhcomp_add, old = "value", new = "hhcomp_add")
    table_hhcomp_add <-
      table_hhcomp_add[, table_row :=
                         as.numeric(gsub("[^\\d]+", "", variable, perl = TRUE))]
    table_hhcomp_add$variable <- NULL
    df <- df[!(variable %in% hhcomp_add_colnames)]

  }
  # CHILD SURVEY TABLES END
  # ##########################

  assign("empty_tables", empty_tables)

  ## Remove tables from main dataset and export to global env
  df <- df[!variable %in% c(questions_scale$V1, contact_flags)]
  df <- dcast(df, country+respondent_id+panel+wave ~ variable)

  match_vars <- c("country", "respondent_id", "panel", "wave", "table_row")

  e <- environment()

  # Generates a message for new or missing question tables
  check_table_names(env = e)
  # Identify question tables and merge to create the final data.table
  tables <- grep("table_", names(e), value = T)
  tables <- grep("participant_table_questions", tables,
                 invert = TRUE, value = TRUE)
  table_names <- mget(unlist(tables))
  
  combine_dt <- Reduce(function(...) merge(..., by = match_vars, all = T), table_names)
  

  x_dt <- merge(df, combine_dt, by = match_vars[-5], all = TRUE)

  return(x_dt)
}

