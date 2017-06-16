###########################################################################################
#### Code to scrape data from Sourceforge.net
############################################################################################

#### Created by: Eirik, Dan, Claire
#### Created on: 06/14/2017
#### Last edited on: 06/16/2017

#Eirik and Dan's Code
#Claire trying to customize


library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "~/git/oss/src/eiriki/01_web_scrape.R")
source(file = "~/git/oss/src/eiriki/03_web_scrape_enterprise.R")
# new code to test

#Getting the first ten pages and storing them into a master list to scrape
master_list <- c()
for(i in 1:200){
  SFTitle_Link <- read_html(paste("https://sourceforge.net/directory/?page=",i, sep=""))

  #Get the list of the titles on the given page
  List_Titles <- SFTitle_Link %>%
    html_nodes('.project_info') %>%
    html_nodes('a') %>%
    html_attr('href')

  #This code will filter out the ads (all links that aren't to projects on sourceforge)
  pattern <- '^/projects'
  match <- grep(pattern = pattern, x = List_Titles)
  List_Titles <- List_Titles[match]


  #copy each title in the list over to the master list
  for(j in 1:25){
    master_list[length(master_list) + 1] <- List_Titles[j]
  }
}
#master_list

#apply the function to the master list and store in a data frame
New_SF <- data.frame()
for(i in 1:length(master_list)){
  new_data <- sf_scrape(master_list[i])

  #Enterprise projects will usually return "Overview" for their descriptions. In that case, call the
  #enterprise_scrape function instead of the normal one.
  if(new_data$Description == "Overview")
  {
    new_data <- enterprise_scrape(master_list[i])
  }
  print(i)
  New_SF<- rbind(New_SF, new_data)
  Sys.sleep(runif(1, 0, 1) * 3)  ## randomly sleep the the system from 0 to 3 seconds
}

orig_data <- New_SF

save(orig_data, file = '~/git/oss/src/ckelling/ScrapingCode/source_forge/orig_SF.Rdata')
