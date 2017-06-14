#this is my attempt at web scraping in R
library(RCurl)
library(XML)
library(stringr)
library(rvest)


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
