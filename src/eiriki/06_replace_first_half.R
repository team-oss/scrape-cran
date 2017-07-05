#this code serves the purpose of scraping only the OSS TITLE, TOTAL DOWNLOAD, AND DESCRIPTION for the first 225,000
#pages
#this is my attempt at web scraping in R
library(RCurl)
library(xml2)
library(stringr)
library(rvest)
library(jsonlite)


sf_scrape_only3 <- function(link){
  #creating the html link to read
  new_link <- paste("https://sourceforge.net", link, sep ="")
  SFLink <- read_html(new_link)

  #Get the Title of OSS
  oss <- SFLink %>%
    html_node('div h1') %>%
    html_text() %>%
    str_trim()

  #Get the Description
  desc <- SFLink %>%
    html_node('div h2') %>%
    html_text() %>%
    str_trim()
  #looking in another place for descriptions if it returns something that isn't a real description
  if(desc == 'Screenshots' | desc == 'Description'){
    desc <- SFLink %>%
      html_node('#description') %>%
      html_text() %>%
      str_trim()
  }

  #Get TOTAL DOWNLOADS from the Download statistics Sourceforge API
  #7/5/2017 this code added to weekly downloads
  new_json_link <- paste0(new_link,'/files/stats/json?start_date=1970-01-01&end_date=2017-07-05')
  total_down <- fromJSON(new_json_link, flatten = TRUE)
  total_down <- total_down$total

  v = list('OSS Title' = oss, 'Description' = desc, 'Total Downloads' = total_down)
  return(data.frame(v, stringsAsFactors = F))
}

enterprise_scrape_only3 <- function(link){
  #creating the html link to read
  new_link <- paste("https://sourceforge.net", link, sep ="")
  SFLink <- read_html(new_link)

  #Get the Title of the Enterprise OSS
  oss <- SFLink %>%
    html_node('.project-name a') %>%
    html_text() %>%
    str_trim()

  #Get the Description, BUT if return NA, look for it in another place
  desc <- SFLink %>%
    html_node('#project-summary') %>%
    html_text() %>%
    str_trim()
  if(is.na(desc)){  #looking in another place for descriptions
    desc <- SFLink %>%
      html_node('#project-description') %>%
      html_text() %>%
      str_trim()
  }

  #Get TOTAL DOWNLOADS from the Download statistics Sourceforge API
  #7/5/2017 this code added with weekly downloads
  new_json_link <- paste0(new_link,'/files/stats/json?start_date=1970-01-01&end_date=2017-07-05')
  total_down <- fromJSON(new_json_link, flatten = TRUE)
  total_down <- total_down$total

  v = list('OSS Title' = oss, 'Description' = desc, 'Total Downloads' = total_down)
  return(data.frame(v, stringsAsFactors = F))
}
