
check_change_vars <- function(df1, df2, verbose = FALSE) {
  lost_vars <- names(df1)[!names(df1) %in% names(df2)]
  gained_vars <- names(df2)[!names(df2) %in% names(df1)]
  
  if(verbose){
    if(length(lost_vars) == 0){
      print("None lost") 
    } else{
      print(paste0("Lost vars: ", lost_vars))
    }
    if(length(gained_vars) == 0){
      print("None lost") 
    } else{
      print(paste0("Gained vars: ",gained_vars))
    }
  }
  list(lost = lost_vars, gained = gained_vars)
}