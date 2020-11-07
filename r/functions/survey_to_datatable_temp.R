

## Loop questions are questions such as what is the age for X?
## Where X may be each contact or household member or something like that.
## This function will seperate the loop questions into different
## datasets called tables. If the loop question is called Q23 then it will
## produce table_q23.

survey_to_datatable_temp <- function(df, export_var_names = FALSE, skip_loop_questions = FALSE){
   empty_tables = NULL
  
  ## Reshape to long format
  df = melt(
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
    qlists <- sapply(
      unique(df[grepl("loop|scale", variable), variable]),
      strsplit, split="_"
    )
    
    # Lapply creates a data.table by looping over the sapply and puting the
    ## Different parts of the varibale names in different columns of the new
    ## data table
    qloops <- rbindlist(
      lapply(qlists,
             function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
      ),
      fill=TRUE
    )
    
    if (!("V5" %in% names(qloops))) qloops[, V5 := NA_character_]
    if (!("V6" %in% names(qloops))) qloops[, V6 := NA_character_]
    if (!("V7" %in% names(qloops))) qloops[, V7 := NA_character_]
    if (!("V8" %in% names(qloops))) qloops[, V8 := NA_character_]
    if (!("V9" %in% names(qloops))) qloops[, V9 := NA_character_]
    
    setnames(qloops, 
             old = c("V1"   , "V2"   , "V3"       , "V4"   , "V5"   , "V6"   , "V7"      , "V8"    , "V9" ) , 
             new = c("qname", "q1num", "loop", "rowid", "q2num", "extra", "extranum", "empty8", "empty9"),
             skip_absent = TRUE)
    
    tail(qloops,20)
    head(qloops,20)
    
    ## Rearrange data to fit correct column as quesitons have different orders    
    qloops[rowid == "scale" & is.na(extra), extra := rowid]
    qloops[rowid == "scale" & q1num != q2num, extranum := q2num]
    qloops[rowid == "scale" & (q1num != q2num | is.na(q2num)), rowid := loop]
    qloops[rowid == "scale" & is.na(q2num), rowid := loop]
    qloops[extra == "scale" & loop != "loop", loop := NA_character_]
    qloops[extra == "scale" & is.na(loop) & (q1num != q2num | is.na(q2num)), q2num := q1num]
    qloops[q2num == "scale", extranum := extra]
    qloops[q2num == "scale", extra := q2num]
    qloops[q2num == "scale", q2num := q1num]
    qloops[is.na(q2num), q2num := q1num]
    
    
    ## If q2num is scale then we've lost the question number so shift one to the right
    
    ## For single scales asked to multiple people
    
    qloops[, newname := paste0(q2num,"_",extra,"_",extranum,"_",empty8)]
    qloops
    qloops[, "newname"] <- sapply(
      strsplit(qloops[, newname], "_"),
      function(x){
        paste0(x[which(x != "NA")], collapse="_")
      }
    )
    
    # ## Create a separate table for for loop question
    for(q in unique(qloops[, q1num])){
      
      ## Pick data for relevant question
      current_q <- qloops[q1num == q]
      
      ## Merge on dataframe information for q
      current_q <- merge(current_q, df, by.x="qname", by.y="variable")
      
      ## Remove empty rows
      current_q <- current_q[!is.na(value)]
      
      ## Re-create table to be wide structure instead of very long
      if(nrow(current_q) > 0){
        ## Reshape to wide x ~ y where x will be rows, y columns
        
        current_q <- dcast(
          current_q,
          country+respondent_id+panel+wave+rowid ~ q2num+extra+extranum+empty8, value.var="value"
        )
        
        ## Order table by respondent_id wave and the row (V4)
        class(current_q$rowid) <- "integer"
        setorder(current_q, country, respondent_id, panel,  wave, rowid)
        colnames(current_q)[which(colnames(current_q) == "rowid")] <- "table_row"
        current_q
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

  # Contact flags
  if(FALSE){
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
  }

  if(FALSE){  
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
  }

  assign("empty_tables", empty_tables)

  ## Remove tables from main dataset and export to global env
  #df <- df[!variable %in% c( contact_flags)]
  df <- dcast(df, country+respondent_id+panel+wave ~ variable)

  match_vars <- c("country", "respondent_id", "panel", "wave", "table_row")

  e <- environment()

  # Generates a message for new or missing question tables
  check_table_names(env = e)
  # Identify question tables and merge to create the final data.table
  tables <- grep("table_", names(e), value = T)
  tables <- grep("participant_table_questions|check_table_names|survey|table_names", tables,
                 invert = TRUE, value = TRUE)
  table_names <- mget(unlist(tables))
  
  combine_dt <- Reduce(function(...) merge(..., by = match_vars, all = T), table_names)
  

  x_dt <- merge(df, combine_dt, by = match_vars[-5], all = TRUE)

  return(x_dt)
}


