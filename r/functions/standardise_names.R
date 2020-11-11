
## Take the Ipsos names and standardise the loop and scale varibles

standardise_names <- function(var){
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
  questions_loop[grepl("loop", p2), scale := "scale"]
  questions_loop[grepl("loop", p2), scalenum := 1]
  
  
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
  
  ## Get rid of the spaces.
  questions_loop[!is.na(qnum), newname := paste(qnum,loop,
                                                loopnum,scale, 
                                                scalenum,text1,text2, 
                                                sep = "_")]
  
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
