#this will handle the case that a project on Sourceforge is an enterprise, which we have to
#scrape differently
library(RCurl)
library(XML)
library(stringr)
library(rvest)

enterprise_scrape <- function(link){
  #creating the html link to read
  new_link <- paste("https://sourceforge.net", link, sep ="")
  SFLink <- read_html(new_link)

  #Get the Title of the Enterprise OSS
  oss <- SFLink %>%
    html_node('.project-name a') %>%
    html_text() %>%
    str_trim()

  #Get the Average Rating
  avg_rat <-SFLink %>%
    html_node('.project-rating') %>%
    html_node('meta') %>%
    html_attr('content') %>%
    str_trim()

  #Get the Description
  desc <- SFLink %>%
    html_node('#project-summary') %>%
    html_text() %>%
    str_trim()

  #Get the Last update
  last_update <- SFLink %>%
    html_node('.dateUpdated') %>%
    html_text() %>%
    str_trim()

  #Get number of Ratings
  num_rat <- SFLink %>%
    html_node('.rating-count') %>%
    html_text() %>%
    str_trim()

  #Get weekly downloads
  week_down <- SFLink %>%
    html_node('.data') %>%
    html_text() %>%
    str_trim()

  #Get the category
  category <- SFLink %>%
    html_node('#breadcrumbs span') %>%
    html_text() %>%
    str_trim()

  #Get the date registered
  date_registered <- SFLink %>%
    html_node('.project-info:nth-child(2) .content') %>%
    html_text() %>%
    str_trim()

  v = list('OSS Title' = oss, 'Average Rating' = avg_rat, 'Description' = desc, 'Last Update' = last_update,
           'Number of Ratings' = num_rat, 'Weekly Downloads' = week_down, 'Category' = category,
           'Date registered' = date_registered)
  return(data.frame(v, stringsAsFactors = F))
}
