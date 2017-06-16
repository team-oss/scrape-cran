###########################################################################################
#### Code to scrape data from Sourceforge.net
############################################################################################

#### Created by: Eirik, Dan, Claire
#### Created on: 06/14/2017
#### Last edited on: 06/16/2017

#Eirik and Dan's Code
#Claire trying to customize

#this is my attempt at web scraping in R
library(RCurl)
library(XML)
library(stringr)
library(rvest)
library(tictoc)
library(data.table)
library(ggplot2)
library(dplyr)

sf_scrape <- function(link){
  #creating the html link to read
  new_link <- paste("https://sourceforge.net", link, sep ="")
  SFLink <- read_html(new_link)

  #Get the Title of OSS
  oss <- SFLink %>%
    html_node('div h1') %>%
    html_text() %>%
    str_trim()

  #Get the Average Rating
  avg_rat <-SFLink %>%
    html_node('section a') %>%
    html_text() %>%
    str_trim()

  #Get the Description
  desc <- SFLink %>%
    html_node('div h2') %>%
    html_text() %>%
    str_trim()

  #Get the Last update
  last_update <- SFLink %>%
    html_node('section time') %>%
    html_text() %>%
    str_trim()

  #Get number of Ratings
  num_rat <- SFLink %>%
    html_node('#counts-sharing span') %>%
    html_text() %>%
    str_trim()

  #Get weekly downloads
  week_down <- SFLink %>%
    html_node('#call-to-action-stats') %>%
    html_text() %>%
    str_trim()

  #Get the category
  category <- SFLink %>%
    html_node('li:nth-child(3) span') %>%
    html_text() %>%
    str_trim()

  #Get the date registered
  date_registered <- SFLink %>%
    html_node('#project-awards+ .project-info .content') %>%
    html_text() %>%
    str_trim()

  v = list('OSS Title' = oss, 'Average Rating' = avg_rat, 'Description' = desc, 'Last Update' = last_update,
           'Number of Ratings' = num_rat, 'Weekly Downloads' = week_down, 'Category' = category,
           'Date registered' = date_registered)
  return(data.frame(v, stringsAsFactors = F))
}

#This is the script to retrieve all projects in sourceforge
#source(file = "src/eiriki/01_web_scrape.R")

#Getting the first three pages and storing them into a master list
master_list <- c()
for(i in 1:1){
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

tic()
#apply the function to the master list and store in a data frame
New_SF <- data.frame()
for(i in 1:length(master_list)){
  print(i)
  new_data <- sf_scrape(master_list[i])
  New_SF<- rbind(New_SF, new_data)
  Sys.sleep(runif(1, 0, 1) * 3)  ## randomly sleep the the system from 0 to 3 seconds
}
toc()

df1=New_SF
ggplot(df1, aes(Category))+ geom_bar()+ theme(axis.text.x = element_text(angle = 90, hjust = 1))

# length(which(df1$category=="Games"))
# df1$category[length(which(df1$category))>1]
# df1= as.data.table(df1)
# test= df1[,.N,category]
# test2 = filter(test, N > 1)

counts <- df1 %>%
  group_by(Category) %>%
  summarise(n = n())

with_counts <- df1 %>% left_join(counts, by= c('Category', 'Category'))
with_counts <- data.frame(with_counts)
df2 <- with_counts[with_counts$n >1, ]

ggplot(df2, aes(Category))+ geom_bar()+ theme(axis.text.x = element_text(angle = 90, hjust = 1))


#initial comments:
#Some bugs with "Share on Facebook" when they are enterprise

orig_data <- New_SF

save(orig_data, file = '~/git/oss/src/ckelling/ScrapingCode/source_forge/orig_SF.Rdata')
