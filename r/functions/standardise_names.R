
## Take the Ipsos names and standardise the loop and scale varibles
#var <- unique(allnames)
standardise_names <- function(var){
  
  #add delimiter to contact
  #var <- gsub("contact","contact_", var)
  
  #initiate standardising names
  questions_loop <- data.table(oldname = var)
  questions_loop[, temp := oldname]
  
  #identify all loop variable (reshaping required)
  questions_loop[grepl("loop", temp), loop := "loop"]
  questions_loop[loop=="loop", temp := gsub("_loop", "", temp)]
  #scale questions also enter loop
  questions_loop[grepl("scale", temp), loop := "loop"]
  
  #scale questions that do not need to be looped/reshaped
  questions_loop[grepl("^q35", temp), loop := ""]
  questions_loop[grepl("^q36", temp), loop := ""]
  questions_loop[grepl("^q37", temp), loop := ""]
  questions_loop[grepl("^q38", temp), loop := ""]
  questions_loop[grepl("^q52", temp), loop := ""]
  questions_loop[grepl("^q53", temp), loop := ""]
  questions_loop[grepl("^q55", temp), loop := ""]
  questions_loop[grepl("^q75", temp), loop := ""]
  questions_loop[grepl("^q76", temp), loop := ""]
  questions_loop[grepl("^q79a", temp), loop := ""]
  questions_loop[grepl("^q80a", temp), loop := ""]
  questions_loop[grepl("^q81a", temp), loop := ""]
  
  #other questions that also need to be reshaped
  #questions_loop[grepl("qmktsize_[0-9]", temp), loop := "loop"]
  questions_loop[grepl("^contact", temp), loop := "loop"]
  questions_loop[grepl("^hhcompconfirm", temp), loop := "loop"]
  questions_loop[grepl("^hhcompremove", temp), loop := "loop"]
  
  #remove the word "scale" from temp
  questions_loop[grepl("scale", temp), scale := "scale"]
  questions_loop[scale=="scale", temp := gsub("_scale1", "", temp)]
  questions_loop[scale=="scale", temp := gsub("_scale", "", temp)]
  
  #split temp into parts
  split <- sapply(
    questions_loop$temp,
    strsplit, split="_"
  )
  split <- rbindlist(
    lapply(split,
           function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
    ),
    fill=TRUE
  )
  questions_loop <- cbind(questions_loop, split[,-1])
  
  #define new qnum
  questions_loop[loop=="loop" & grepl("^q",V4), qnum:= V4]
  questions_loop[loop=="loop" & is.na(qnum), qnum:= V2]
  
  questions_loop[loop=="loop" & !is.na(scale), qnum:= paste(qnum, scale, sep="_")]
  questions_loop[loop=="loop" & !is.na(V4) & !grepl("^q",V4), qnum:= paste(qnum, V4, sep="_")]

  questions_loop[loop=="loop" & !is.na(V5), qnum:= paste(qnum, V5, sep="_")]
  questions_loop[loop=="loop" & !is.na(V6), qnum:= paste(qnum, V6, sep="_")]
  
  #rename table name and table_row
  setnames(questions_loop,"V2","table")
  setnames(questions_loop,"V3","table_row")
  
  questions_loop[loop == "", loop := NA]
  
  questions_loop[is.na(loop), newname := oldname]
  questions_loop[is.na(loop), table := oldname]
  questions_loop[is.na(loop), table_row := "0"]
  questions_loop[!is.na(loop), newname := paste(qnum, table_row, sep="_")]
  
  questions_loop$qnum <- trimws(questions_loop$qnum)
  
  questions_loop <- questions_loop[,list(oldname, table, table_row, newname, qnum, loop)]
  
  # questions_lists <- sapply(
  #   var,
  #   strsplit, split="_"
  # )
  # 
  # questions_loop <- rbindlist(
  #   lapply(questions_lists,
  #          function(x){ as.data.table(t(c(paste0(x,collapse="_"),x))) }
  #   ),
  #   fill=TRUE
  # )
  # # Change from V1 to p1 where p = part and number is the part of the questions
  # setnames(questions_loop, 
  #          old = c("V1"     , "V2", "V3", "V4", "V5", "V6", "V7", "V8") , 
  #          new = c("oldname", "p1", "p2", "p3", "p4", "p5", "p6", "p7"),
  #          skip_absent = TRUE)
  # 
  # 
  # # Loop questions overall --------------------------------------------------
  # 
  # 
  # ## Useful for all loops
  # ## Sometimes the question number is in part 2 or part 4
  # questions_loop[grepl("loop", p2) & grepl("q[0-9].*", p4), qnum := p4]
  # questions_loop[grepl("loop", p2) & !grepl("q[0-9].*", p4), qnum := p1]
  # 
  # ## Loop text is always in part 2. 
  # questions_loop[grepl("loop", p2), loop := p2]
  # ## The row is for the loop is always in part 3
  # questions_loop[grepl("loop", p2), loopnum := as.numeric(p3)]
  # ## Add the text scale and put 1 for a constant scale number for consistency
  # questions_loop[grepl("loop", p2), scale := NA_character_]
  # questions_loop[grepl("loop", p2), scalenum := p5]
  # 
  # 
  # ## There is extra text of date, codes, filter in parts 4, 5, and 6
  # questions_loop[grepl("loop", p2) & !grepl("[0-9].*", p5) & !is.na(p5), text1 := p5]
  # questions_loop[grepl("loop", p2) & !grepl("[0-9].*", p5) & !is.na(p5), text2 := p6]
  # questions_loop[grepl("loop", p2) & !grepl("scale", p4) & !grepl("q[0-9].*", p4), text1 := p4]
  # 
  # #unique(questions_loop$text2)
  # #questions_loop[grepl("loop", p2) & !grepl("q[0-9].*", p5) & !is.na(p5),]
  # 
  # 
  # # Loops with scale in p4 --------------------------------------------------
  # ## Loop scale single scale in part 4
  # questions_loop[grepl("scale", p4), scale := p4]
  # 
  # #questions_loop[grepl("scale", p4)]
  # 
  # 
  # # Loops with scale in part 6 ----------------------------------------------
  #   
  # ## Loop scale multi scale in part 6
  # unique(questions_loop[grepl("scale", p6)]$text1)
  # questions_loop[grepl("scale", p6), scale := p6]
  # questions_loop[grepl("scale", p6), scalenum := as.numeric(p5)]
  # questions_loop[grepl("scale", p6), text1 := p7]
  # 
  # #questions_loop[grepl("scale", p6) & !is.na(text1)]
  # #questions_loop[grepl("scale", p6) & is.na(text1)]
  # 
  # 
  # # Scale question without loop ---------------------------------------------
  # 
  # ## Scale had a number before which is the row_id
  # ## They will be a single variable with a zero after it.
  # ## single or multi scale for multiple people
  # questions_loop[grepl("scale", p3), qnum := p1]
  # questions_loop[grepl("scale", p3), loop := "loop"]
  # questions_loop[grepl("scale", p3), loopnum := as.numeric(p2)]
  # questions_loop[grepl("scale", p3), scale := p3]
  # questions_loop[grepl("scale", p3) & !grepl("original", p4), scalenum := as.numeric(p4)]
  # questions_loop[grepl("scale", p3) & is.na(scalenum), scalenum := 1]
  # questions_loop[grepl("scale", p3) & grepl("original", p4), text1 := p4]
  # 
  # #questions_loop[grepl("scale", p3) & !is.na(text1)]
  # 
  # # Extra variables for contacts and households -----------------------------
  # questions_loop[grepl("contact", oldname), 
  #                loopnum := as.numeric(stringr::str_extract(p1, "[0-9].*"))]
  # questions_loop[grepl("contact", oldname), loop := "loop"]
  # questions_loop[grepl("contact", oldname), qnum := stringr::str_remove(p1, "[0-9].*" )]
  # 
  # hhcomps <- "hhcompcon|hhcomprem"
  # questions_loop[grepl(hhcomps, oldname), loop := "loop"]
  # questions_loop[grepl(hhcomps, oldname), loopnum := as.numeric(p2)]
  # questions_loop[grepl(hhcomps, oldname), qnum:= p1]
  # #questions_loop[grepl("contact", oldname)]
  # 
  # ## Get rid of the spaces.
  # 
  # questions_loop[!is.na(qnum), newname := paste(qnum,loop,
  #                                               loopnum,scale, 
  #                                               scalenum,text1,text2, 
  #                                               sep = "_")]
  # 
  # 
  # 
  # 
  # #table(questions_loop[grepl("q72", p4)]$newname)
  # #table(questions_loop[grepl("q48", p1)]$newname)
  # #table(is.na(questions_loop$qnum))
  # questions_loop[is.na(newname), newname := oldname]
  # 
  # questions_loop[, "newname"] <- sapply(
  #   strsplit(questions_loop[, newname], "_"),
  #   function(x){
  #     paste0(x[which(x != "NA")], collapse="_")
  #   }
  # )
  questions_loop
}


