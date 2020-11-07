## check_table_names run in the survery_to_datatable script. It
## checks whether the expected tables are in the data.

check_table_names <- function(env) {
  env_tables <- grep("table_", names(env), value = TRUE)
  new_tables <- setdiff(env_tables, expected_tables)
  missing_tables <- setdiff(expected_tables, env_tables)
  
  if (length(new_tables) > 0) {
    message(paste(
      c("Warning Messange : \nAdd the following new table(s) to the `expected_tables` variable:",
        new_tables), collapse = "\n"))
    # fwrite(new_tables, "data/uk/new_tables.csv")
  }
  if( length(missing_tables) > 0) {
    message(paste(
      c("Warning Messange : \nThe following table(s) are missing:",
        missing_tables), collapse = "\n"))
  }
}

expected_tables <- c(
  "table_q76_3_scale3", "table_q76_2_scale3", "table_q76_1_scale3",
  "table_q76_3_scale2", "table_q76_2_scale2", "table_q76_1_scale2",
  "table_q76_3_scale1", "table_q76_2_scale1", "table_q76_1_scale1",
  "table_q75_3_scale3", "table_q75_2_scale3", "table_q75_1_scale3",
  "table_q75_3_scale2", "table_q75_2_scale2", "table_q75_1_scale2",
  "table_q75_3_scale1", "table_q75_2_scale1", "table_q75_1_scale1",
  "table_q63", "table_q62", "table_q34", "table_q33", "table_q30",
  "table_q29", "table_q28", "table_q21", "participant_table_questions",
  "table_q66", "table_q51", "table_q50", "table_q49", "table_q48a",
  "table_q48", "table_q47", "table_q46", "table_q45", "table_q44",
  "table_q43", "table_q42", "table_q41", "table_q40", "table_q39",
  "table_q31", "table_q23", "table_contact_flag")



