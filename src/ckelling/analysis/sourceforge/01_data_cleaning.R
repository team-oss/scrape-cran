###########################################################################################
#### Code to clean data from Sourceforge.net
############################################################################################

#### Created by: Claire
#### Created on: 06/14/2017
#### Last edited on: 07/05/2017

#load("~/git/oss/src/ckelling/ScrapingCode/source_forge/orig_SF.Rdata")
library(tictoc)
library(stringr)
#
# tic()
# fs <- list.files('~/git/oss/data/oss/original/sourceforge/SF_scrape_FINAL', full.names = TRUE, pattern = '*.RData')
#
# load_stuff <- function(file_name) {
#   load(file_name)
#   return(data.frame(new_data, stringsAsFactors = F))
# }
#
# fl <- lapply(X = fs, FUN = load_stuff)
#
# complete_SFdat <- data.table::rbindlist(fl)
# toc()
#
# complete_SFdat <- complete_SFdat2
# #this is the percent of errors, where we were unable to collect
# 1- nrow(complete_SFdat)/225000
#
# #save(complete_SFdat, file = '~/git/oss/data/oss/working/sourceforge/complete_SFdat.RData')
# save(complete_SFdat2, file = '~/git/oss/data/oss/working/sourceforge/complete_SFdat2.RData')


load(file = '~/git/oss/data/oss/working/sourceforge/DONE_SFunclean.RData')

New_SF <- complete_data

###
#data cleaning
###

#cleaning Average Rating
#unique(New_SF$Average.Rating)

avgrate_clean=function(data){
  #data=New_SF$Average.Rating[121858]
  if(length(grep('Downloads',data)) == 0){
    if(is.na(data)==TRUE){
      return(NA)
    }else if(data == "Add a Review"){
      return(NA)
    }else if(nchar(data)==9){
      return(as.numeric(substr(data, 1, nchar(data)-6)))
    }else{
      return(as.numeric(data))
    }
  }else{
    return(NA)
  }
}

New_SF$Average.Rating = lapply(New_SF$Average.Rating, FUN=avgrate_clean)


#cleaning Description
desc_clean=function(data){
  if(data == "Description"){
    return(NA)
  }else{
    return(data)
  }
}
New_SF$Description = lapply(New_SF$Description, FUN=desc_clean)


#cleaning last update
day_set <- grep('day', New_SF$Last.Update, TRUE)
hour_set <- grep('hour',New_SF$Last.Update, TRUE)

#needs fixing
extract_date <- Sys.Date()-1
dateup_clean = function(data){
  if(length(grep('day', data)) == 0){
    if(length(grep('hour',data))==0){
      if(length(grep('minute',data))==0){
        return(data)
      }else if(grep('minute',data)==1){
        return(as.character(extract_date))
      }
    }else if(grep('hour',data)==1){
      return(as.character(extract_date))
    }
  }else if(grep('day', data) == 1){
    return(as.character(as.Date(extract_date - as.numeric(substr(data,1,1)))))
  }else{
    return('error')
  }
}
New_SF$Last.Update <- lapply(New_SF$Last.Update, FUN=dateup_clean)
#New_SF$Last.Update2= lubridate::ymd[New_SF$Last.Update2]
New_SF$Date.registered <- lapply(New_SF$Date.registered, FUN=dateup_clean)

#rating cleaning
numrate_clean=function(data){
  if(is.na(data) == TRUE){
    return(NA)
  }else if(data == "(This Week)"){
    return(0)
  }else if(is.na(data)==FALSE){
    return(as.numeric(substr(data, 2, nchar(data)-1)))
  }else{
    return(NA)
  }
}
New_SF$Number.of.Ratings = lapply(New_SF$Number.of.Ratings, FUN=numrate_clean)


#downloads cleaning
down_clean=function(data){
  if(length(grep('Downloads',data))==0){
    as.numeric(gsub(",", "",substr(data, 1, nchar(data)-9)))
  }else{
    as.numeric(gsub(",", "",substr(data, 1, nchar(data)-10)))
  }
}
New_SF$Weekly.Downloads = lapply(New_SF$Weekly.Downloads, FUN=down_clean)


#ease/features/design/support cleaning
rate_clean=function(data){
  if(is.na(data) == TRUE){
    return(NA)
  }else if(is.na(data)==FALSE){
    return(as.numeric(substr(data, 1, 2)) / as.numeric(substr(data, nchar(data)-1, nchar(data))))
  }else{
    return(NA)
  }
}
New_SF$Ease = lapply(New_SF$Ease, FUN=rate_clean)
New_SF$features = lapply(New_SF$features, FUN=rate_clean)
New_SF$design = lapply(New_SF$design, FUN=rate_clean)
New_SF$support = lapply(New_SF$support, FUN=rate_clean)

New_SF$Total.Downloads = as.numeric(New_SF$Total.Downloads)

cleaned_SF <- New_SF


save(cleaned_SF, file = '~/git/oss/data/oss/working/sourceforge/DONE_SFclean.RData')
