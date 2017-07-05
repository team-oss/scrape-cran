###########################################################################################
#### Code to scrape data from Sourceforge.net
############################################################################################

#### Created by: Eirik, Dan, Claire
#### Created on: 06/14/2017
#### Last edited on: 07/05/2017

#Eirik and Dan's Code
#Claire trying to customize
#try to scrape for 488,907

library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "~/git/oss/src/eiriki/06_replace_first_half.R")

#Getting the 400,000+ pages
load("~/git/oss/data/oss/original/sourceforge/master_list_FINAL/List_Titles_df.RData")
master_list_2 <- as.vector(List_Titles_df[,1])

sf_newname <- function(x){
  x <- substr(x, 24, nchar(x))
  new<- paste("/", unlist(str_split(x, "/", n = 4))[2], "/", unlist(str_split(x, "/", n = 4))[3], "/", sep = "")
  return(new)
}
master_list_2 <- sapply(master_list_2, sf_newname)

#test <- as.data.frame(master_list_2)


#apply the function to the master list and store in a data frame
New_SF <- data.frame()

error_vec <- c()
#load("~/git/oss/data/oss/original/sourceforge/errors.Rdata")
#error_vec <- as.vector(error_vec[1,])
#error_vec <- (error_vec[1:400,])
error_vec <- c(1294,1639)
error_vec <- as.data.frame(error_vec)
#error_vec <- as.vector(error_vec[,1])
error_vec[,1] <- as.character(error_vec[,1])
class(error_vec)

for(i in 2311:225000){
  #for(i in 213737:213739){
  #i=213739
  new_data <- try(sf_scrape_only3(master_list_2[i]))

  if(substr(new_data[1],1,5) == "Error"){
    num = paste(i)
    num = as.character(num)
    error_vec <- rbind(error_vec, num)
    save(error_vec, file = '~/git/oss/data/oss/original/sourceforge/need_to_append/errors.Rdata')
  }else{
    #Enterprise projects will usually return "Overview" for their descriptions. In that case, call the
    #enterprise_scrape function instead of the normal one.
    if(new_data$Description == "Overview")
    {
      new_data <- enterprise_scrape_only3(master_list_2[i])
    }
    print(i)
    New_SF<- rbind(New_SF, new_data)
    Sys.sleep(runif(1, 0, 1) * 2)  ## randomly sleep the the system from 0 to 2 seconds
    save(new_data, file= sprintf('~/git/oss/data/oss/original/sourceforge/need_to_append/data/SF_%06d.RData', i))
  }
}

#load('~/git/oss/data/oss/original/sourceforge/SF_scrape_FINAL/SF_213296.RData')

#full_SF <- New_SF
#save(full_SF, file = '~/git/oss/data/oss/original/sourceforge/FINAL_full_data/full_SF.Rdata')

#fullerror_vec <- error_vec
#save(fullerror_vec, file = '~/git/oss/data/oss/original/sourceforge/FINAL_full_data/fullerrors.Rdata')

