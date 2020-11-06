## Changing the names of SPSS files using a dictionary


## This should be moved to functions and checked to see if it works. 
change_names <- function(df, varnames, c_code) {
  c_codes <- c(be = "be", uk = "uk", nl = "nl", no = "no")
  remove <- paste(setdiff(c_codes, c_code), collapse = "|")
  keep <- grep(remove, varnames$var, invert = T, value = T)
  varnames <- varnames[var %in% keep]
  varnames[, new_name := gsub(" ", "", new_name)]
  index_name <- match(names(df), varnames$var)
  index_name <- index_name[!is.na(index_name)]
  df <- df[, varnames$var[index_name], with = FALSE]
  
  index_name <- match(names(df), varnames$var)
  index_name <- index_name[!is.na(index_name)]
  new_names <- as.character(varnames$new_name[index_name])
  setnames(df, old = names(df), new = new_names)
  
  df
}

change_namesv2 <- function(df, varnames, c_code) {
  loops <- grep("loop|contact[1-100]|contact[900-998]|hhcompremove_[0-9]|hhcompadd_[0-9]|_i$", names(df), value = T)
  df <- df[, -loops, with = F]
  
  c_codes <- c(be = "be", uk = "uk", nl = "nl", no = "no")
  remove <- paste(setdiff(c_codes, c_code), collapse = "|")
  keep <- grep(remove, varnames$var, invert = T, value = T)
  varnames <- varnames[var %in% keep]
  
  index_name <- match(names(df), varnames$var)
  index_name <- index_name[!is.na(index_name)]
  df <- df[, varnames$var[index_name], with = FALSE]
  index_name <- match(names(df), varnames$var)
  index_name <- index_name[!is.na(index_name)]
  new_names <- as.character(varnames$new_name[index_name])
  old_names <- names(df)
  
  matched <- grep("[0-9]|[a-z]", new_names)
  new_names <- new_names[matched]
  old_names <- old_names[matched]
  df <- df[, old_names, with = F]
  
  names(df) <- new_names
  
  df
}