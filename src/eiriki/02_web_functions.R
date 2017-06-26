#This is the script to retrieve all projects in sourceforge
library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "~/git/lab/oss/src/eiriki/01_web_scrape.R")
source(file = "~/git/lab/oss/src/eiriki/03_web_scrape_enterprise.R")
library(tictoc)

#Getting ALL pages and storing them into a master list to scrape
master_list <- c()
tic()
#18810
for(i in 1355:18810){
  SFTitle_Link <- read_html(paste("https://sourceforge.net/directory/?page=",i, sep=""))
  print(i)
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
  for(j in 1:length(List_Titles)){
    new_dat <- List_Titles[j]
    save(new_dat, file= sprintf('~/git/lab/oss/data/oss/original/sourceforge/master_list/SF_%06d_%02d.RData', i, j))
    master_list[length(master_list) + 1] <- List_Titles[j]
  }
  #save(master_list, file= sprintf('~/git/lab/oss/data/oss/original/sourceforge/new_data/SF_%06d.RData', i))
}
toc()
