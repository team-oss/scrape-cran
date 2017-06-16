###########################################################################################
#### Code to clean data from Sourceforge.net
############################################################################################

#### Created by: Claire
#### Created on: 06/14/2017
#### Last edited on: 06/16/2017

load("~/git/oss/src/ckelling/ScrapingCode/source_forge/orig_SF.Rdata")

New_SF <- orig_data

#data cleaning
#downloads cleaning
down_clean=function(data){
  as.numeric(gsub(",", "",substr(data, 1, nchar(data)-10)))
}
New_SF$Weekly.Downloads = lapply(New_SF$Weekly.Downloads, FUN=down_clean)

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

#cleaning Average Rating
avgrate_clean=function(data){
  if(nchar(data)==9){
    return(as.numeric(substr(data, 1, nchar(data)-6)))
  }else{
    return(NA)
  }
}
New_SF$Average.Rating = lapply(New_SF$Average.Rating, FUN=avgrate_clean)


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

cleaned_var <- New_SF

save(cleaned_var, file = 'src/ckelling/ScrapingCode/source_forge/new_SF.Rdata')
