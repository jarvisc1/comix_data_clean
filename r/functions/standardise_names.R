
## Take the Ipsos names and standardise the loop and scale variables
#var <- unique(allnames)
standardise_names <- function(var, original_survey = FALSE){
  questions_lists <- sapply(
    var,
    strsplit, split="_"
  )
  
  questions_loop <- rbindlist(
    lapply(questions_lists,
           function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
    ),
    fill=TRUE
  )
  # Change from V1 to p1 where p = part and number is the part of the questions
  setnames(questions_loop, 
           old = c("V1"     , "V2", "V3", "V4", "V5", "V6", "V7", "V8") , 
           new = c("oldname", "p1", "p2", "p3", "p4", "p5", "p6", "p7"),
           skip_absent = TRUE)
  
  

  # Loop questions overall --------------------------------------------------

  
  ## Useful for all loops
  ## Sometimes the question number is in part 2 or part 4
  questions_loop[grepl("loop", p2) & grepl("q[0-9].*", p4), qnum := p4]
  questions_loop[grepl("loop", p2) & !grepl("q[0-9].*", p4), qnum := p1]
  
  ## Loop text is always in part 2. 
  questions_loop[grepl("loop", p2), loop := p2]
  ## The row is for the loop is always in part 3
  questions_loop[grepl("loop", p2), loopnum := as.numeric(p3)]
  ## Add the text scale and put 1 for a constant scale number for consistency
  questions_loop[grepl("loop", p2), scale := NA_character_]
  questions_loop[grepl("loop", p2) & grepl("^[0-9].*", p5), scalenum := p5]
  
  
  ## There is extra text of date, codes, filter in parts 4, 5, and 6
  questions_loop[grepl("loop", p2) & !grepl("[0-9].*", p5) & !is.na(p5), text1 := p5]
  questions_loop[grepl("loop", p2) & !grepl("[0-9].*", p5) & !is.na(p5), text2 := p6]
  questions_loop[grepl("loop", p2) & !grepl("scale", p4) & !grepl("q[0-9].*", p4), text1 := p4]
  
  #unique(questions_loop$text2)
  #questions_loop[grepl("loop", p2) & !grepl("q[0-9].*", p5) & !is.na(p5),]
  

  # Loops with scale in p4 --------------------------------------------------
  ## Loop scale single scale in part 4
  questions_loop[grepl("scale", p4), scale := p4]

  #questions_loop[grepl("scale", p4)]
  

  # Loops with scale in part 6 ----------------------------------------------
    
  ## Loop scale multi scale in part 6
  unique(questions_loop[grepl("scale", p6)]$text1)
  questions_loop[grepl("scale", p6), scale := p6]
  questions_loop[grepl("scale", p6), scalenum := as.numeric(p5)]
  questions_loop[grepl("scale", p6), text1 := p7]
  
  #questions_loop[grepl("scale", p6) & !is.na(text1)]
  #questions_loop[grepl("scale", p6) & is.na(text1)]
  

  # Scale question without loop ---------------------------------------------
  
  ## Scale had a number before which is the row_id
  ## They will be a single variable with a zero after it.
  ## single or multi scale for multiple people
  questions_loop[grepl("scale", p3), qnum := p1]
  questions_loop[grepl("scale", p3), loop := "loop"]
  questions_loop[grepl("scale", p3), loopnum := as.numeric(p2)]
  questions_loop[grepl("scale", p3), scale := p3]
  questions_loop[grepl("scale", p3) & !grepl("original", p4), scalenum := as.numeric(p4)]
  questions_loop[grepl("scale", p3) & is.na(scalenum), scalenum := 1]
  questions_loop[grepl("scale", p3) & grepl("original", p4), text1 := p4]
  
  #questions_loop[grepl("scale", p3) & !is.na(text1)]

  # Extra variables for contacts and households -----------------------------
  questions_loop[grepl("contact", oldname), 
                 loopnum := as.numeric(stringr::str_extract(p1, "[0-9].*"))]
  questions_loop[grepl("contact", oldname), loop := "loop"]
  questions_loop[grepl("contact", oldname), qnum := stringr::str_remove(p1, "[0-9].*" )]
  
  hhcomps <- "hhcompcon|hhcomprem"
  questions_loop[grepl(hhcomps, oldname), loop := "loop"]
  questions_loop[grepl(hhcomps, oldname), loopnum := as.numeric(p2)]
  questions_loop[grepl(hhcomps, oldname), qnum:= p1]
  #questions_loop[grepl("contact", oldname)]
  
  
  
    # Exceptions --------------------------------------------------------------

    # Attitude and behaviour questions ----------------------------------------
    questions_loop[grepl("q35_[0-9].*_scale", oldname), newname := paste("q35_scale", p2, sep = "_")]
    questions_loop[grepl("q36_[0-9].*_scale", oldname), newname := paste("q36_scale", p2, sep = "_")]
    questions_loop[grepl("q37_[0-9].*_scale", oldname), newname := paste("q37_scale", p2, sep = "_")]
    questions_loop[grepl("q38_[0-9].*_scale", oldname), newname := paste("q38_scale", p2, sep = "_")]
    questions_loop[grepl("q35", oldname),]

    # Visiting places ---------------------------------------------------------
    questions_loop[grepl("q52_[0-9].*_scale", oldname), newname := paste("q52",p3, p2, sep = "_")]
    questions_loop[grepl("q52", oldname)]
    
    questions_loop[grepl("q53_loop_[0-9].*", oldname), newname := paste("q53_scale", p3,p5,p6, sep = "_")]
    questions_loop[grepl("q53", oldname)]
    questions_loop[grepl("q55_[0-9].*_scale", oldname), newname := paste("q55_scale", p2, sep = "_")]
    questions_loop[grepl("q55", oldname)]
    
    
    questions_loop[grepl("q60_loop_[0-9].*", oldname), newname := paste("q60", p6, p3,p5, sep = "_")]
    questions_loop[grepl("q60", oldname)]

    questions_loop[grepl("q60", oldname) , text1 := p5]
    questions_loop[grepl("q60", oldname) , scalenum := p3]
    questions_loop[grepl("q60", oldname) , loopnum := 0]
    ## Mass contacts
    questions_loop[grepl("q75_[0-9].*_scale", oldname), newname := paste("q75", p2,p3, sep = "_")]
    questions_loop[grepl("q75", oldname)]
    questions_loop[grepl("q76_[0-9].*_scale", oldname), newname := paste("q76", p2,p3, sep = "_")]
    questions_loop[grepl("q76", oldname)]
    questions_loop[grepl("q79a_[0-9].*_scale", oldname), newname := paste("q79a", p2,p3, sep = "_")]
    questions_loop[grepl("q80a_[0-9].*_scale", oldname), newname := paste("q80a", p2,p3, sep = "_")]
    questions_loop[grepl("q81a_[0-9].*_scale", oldname), newname := paste("q81a", p2,p3, sep = "_")]
    questions_loop[grepl("q79a", oldname)]
    questions_loop[grepl("q80a", oldname)]
    questions_loop[grepl("q81a", oldname)]
    


  
  
  ## Get rid of the spaces.
  
  questions_loop[!is.na(qnum) & is.na(newname), newname := paste(qnum,loop,
                                                loopnum,scale, 
                                                scalenum,text1,text2, 
                                                sep = "_")]
  
  
  
  
  #table(questions_loop[grepl("q72", p4)]$newname)
  #table(questions_loop[grepl("q48", p1)]$newname)
  #table(is.na(questions_loop$qnum))
  questions_loop[is.na(newname), newname := oldname]
  
  questions_loop[, "newname"] <- sapply(
    strsplit(questions_loop[, newname], "_"),
    function(x){
      paste0(x[which(x != "NA")], collapse="_")
    }
  )
  questions_loop$newname
}
