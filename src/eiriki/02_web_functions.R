#This is the script to retrieve all projects in sourceforge
library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "src/eiriki/01_web_scrape.R")

#Getting the first ten pages and storing them into a master list
master_list <- c()
for(i in 1:10){
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
master_list

#apply the function to the master list and store in a data frame
sf_scrape(master_list[1])
New_SF <- data.frame(OSS, avg_rat, Desc, last_update, num_rat, week_down,category,date_registered, stringsAsFactors = F)

for(i in 2:length(master_list)){
  sf_scrape(master_list[i])
  New_SF<- rbind(New_SF, c(OSS, avg_rat, Desc, last_update, num_rat, week_down, category, date_registered))
  Sys.sleep(runif(1, 0, 1) * 10)  ## randomly sleep the the system from 0 to 10 seconds
}
