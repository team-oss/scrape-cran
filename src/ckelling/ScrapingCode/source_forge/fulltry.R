###########################################################################################
#### Code to scrape data from Sourceforge.net
############################################################################################

#### Created by: Eirik, Dan, Claire
#### Created on: 06/14/2017
#### Last edited on: 06/16/2017

#Eirik and Dan's Code
#Claire trying to customize
#try to scrape for 40,000

library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "~/git/oss/src/eiriki/01_web_scrape.R")
source(file = "~/git/oss/src/eiriki/03_web_scrape_enterprise.R")
# new code to test

#Getting the 40,000+ pages
load(file= "~/git/oss/data/oss/original/sourceforge/master_list_2/master_list_2.RData")
master_list_2 <- as.vector(master_list_2[,1])

#apply the function to the master list and store in a data frame
New_SF <- data.frame()
for(i in 3908:length(master_list_2)){
  new_data <- sf_scrape(master_list_2[i])

  #Enterprise projects will usually return "Overview" for their descriptions. In that case, call the
  #enterprise_scrape function instead of the normal one.
  if(new_data$Description == "Overview")
  {
    new_data <- enterprise_scrape(master_list_2[i])
  }
  print(i)
  New_SF<- rbind(New_SF, new_data)
  Sys.sleep(runif(1, 0, 1) * 3)  ## randomly sleep the the system from 0 to 3 seconds
  save(new_data, file= sprintf('~/git/oss/data/oss/original/sourceforge/new_data/SF_%06d.RData', i))
}

full_SF <- New_SF

save(full_SF, file = '~/git/oss/data/oss/original/sourceforge/full_SF.Rdata')
