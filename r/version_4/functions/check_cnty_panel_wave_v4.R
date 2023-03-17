## Take a data.table and a country and perform checks for whether
## the country, wave, and panel, align with the spread sheet
## and if not present then add them.


country_checker = function(dta, country, force_ = FALSE){
  
  dta = data.table::as.data.table(dta)
  # Check if variable is in data
  var = names(dta)[stringr::str_detect(names(dta), "^country")]
  if(length(var) > 1) var = var[var == "country"]
  # If so create a check of the values
  if(length(var) > 0) check = tolower(unique(dta[[var]]))
  ## Get the values for the data

  if(length(var)  == 0){
    
    warning(paste0("\nEmpty country changing to ", country))
    dta$country = country
    return(dta)
    
  } else if(!country %in% check){
    
    checks = paste(check, collapse = " ")
    stop(paste0("\nCountry in data differs from input\n",
               "Data country = ", checks,"\n",
               "Input country = ", country),"\n",
         "Check input data and SPSS spreadsheet.")
    
  } else if(length(check) > 1){
    
    checks = paste(check, collapse = " ")
    
    warning(paste0("\nMultiple countries: ", 
                  checks,"\n",
                  "Filtering data to:  ", country))
    
    check = check[check == country & !is.na(check)]
    dta[[var]] = tolower(dta[[var]])
    print(check)
    dta = dta[get(var) == check]
    dta$country = country
    
    return(dta)
    
  } else if(is.na(check)){
    warning(paste0("\nCountry variable but values missing changing to ", country))
    dta$country = country
 
    return(dta)
    
  } else if(check == country){
    
    dta$country = country
    
    return(dta)
    
  } else{
    
    stop("Country Error")
    
  }
}

panel_checker = function(dta, panel){
  
  dta = data.table::as.data.table(dta)
  # Check if variable is in data
  var = names(dta)[stringr::str_detect(names(dta), "panel")]
  if(length(var) > 1) var = var[var == "panel"]
  # If so create a check of the values
  if(length(var) > 0) {
    check = toupper(unique(dta[[var]]))
    check = tolower(check)
    check = stringr::str_remove(check, "^panel")
    check = trimws(check)
    check = toupper(check)
  }
    
  if(length(var)  == 0){
    warning(paste("Empty Panel changing to", panel))
    dta$panel = panel
    return(dta)
      
    
  } else if(!panel %in% check){
    
    #assign additional children waves to Panel D (currently also C, same as original waves)
    if(panel=="D" & check=="C"){
      warning(paste("\nPanel changing from", check, "to", panel, "(additional children waves)\n"))
      dta$panel = panel
      return(dta)
    } else if(!(panel=="D" & check=="C")){
  
    checks = paste(check, collapse = " ")
    
    stop(paste0("\nPanel in data differs from input \n",
                "Data panel = ", checks,"\n",
                "Input panel = ", panel),"\n",
         "Check input data and SPSS spreadsheet.")
    }

  } else if(length(check) > 1 ){
    
    checks = paste(check, collapse = " ")
    
    stop(paste0("\nMultiple Panels: ", 
                checks,"\n",
                "Adding panel variable with these panels"))
    
    dta$panel = dta[[pan_var]]
    
    return(dta)
 
  } else if(is.na(check)){
    warning(paste0("\nPanel variable but values missing changing to ", panel))
    dta$panel = panel
    return(dta)
  
  } else if(check == panel){
    
    dta[[var]] = NULL
    dta$panel = panel
    
    return(dta)
  
  } else{
    
    stop("Panel Error")
    
  }
}


# could update to deal with multiple waves
wave_checker = function(dta, wave){
  
  
  dta = data.table::as.data.table(dta)
  # Check if variable is in data
  var = names(dta)[stringr::str_detect(names(dta), "wave$")]
  if(length(var) > 1) var = var[var == "wave"]
  # If so create a check of the values
  if(length(var) > 0) {
    check = tolower(unique(dta[[var]]))
    check = as.numeric(stringr::str_extract(check, "[0-9]{1,2}"))
  }
  if(length(var)  == 0){
    warning(paste("Empty wave changing to", wave))
    dta$wave = as.numeric(wave)
    dta$wave = as.numeric(dta$wave)
    return(dta)

  } else if(length(check) > 1 ){
    
    checks = paste(check, collapse = " ")
    stop(paste0("\nMultiple waves: ", 
                checks,"\n",
                "Has data type changed?\n",
                "If so update dm_02_data_clean \n",
                "wave_checker to handle multiple wave."))
    
  } else if(is.na(check)){
    warning(paste0("\nWave variable but values missing changing to ", country))
    dta$wave = wave
    return(dta)
    
  } else if(!wave %in% check){
    
    checks = paste(check, collapse = " ")
    stop(paste0("\nWave in data differs from input \n",
                "Data wave = ", checks,"\n",
                "Input wave = ", wave),"\n",
         "Check input data and SPSS spreadsheet.")
    
    
  } else if(check == wave){
    dta[[var]] = NULL
    dta$wave = as.numeric(wave)
    
    return(dta)
    
  } else{
    stop("Wave Error")
  }
  
}

