#this is my attempt at web scraping in R
library(RCurl)
library(xml2)
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
  #looking in another place for descriptions if it returns "Screenshots" (not real description)
  if(desc == 'Screenshots'){
    desc <- SFLink %>%
      html_node('#description') %>%
      html_text() %>%
      str_trim()
    }


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

  #Tell me that this page is NOT an enterprise page (if it is, it will change to a diff function: detect later)
  is_enterpise <- "Project"

  #Get the categories
  category <- SFLink %>%
    html_nodes('#breadcrumbs li~ li+ li span') %>%
    html_text() %>%
    str_trim()

  #Get the date registered ONLY IF THIS PAGE IS NOT AN ENTERPRISE PAGE. Otherwise, return NA
  if(desc != "Overview") #Enterprise pages will usually return "Overview" for description
  {
  #Get all "additional details" nodes
  date_registered <- SFLink %>%
    html_nodes('#project-additional-trove .content') %>%
    html_text() %>%
    str_trim()

  #filter out for the date
  match <- grep(pattern = '20', x = date_registered)
  date_registered <- date_registered[match]
  }
  else{
    date_registered <- NA
  }

  #Get the authors in "Brought to you by"
  authors <- SFLink %>%
    html_nodes('#maintainers span') %>%
    html_text() %>%
    str_trim() %>%
    paste(collapse = ', ')

  #6/20 the code below does not work. trying xpath stuff to no avail.
  #social_media <- SFLink %>%
    #xml_find_all('//*[@id="aggregateCount"]') %>%
    #xml_text() %>%
    #str_trim()
  #User features: ease, features, design, support (ratings for reach)
  #Intended Audience (ex: developers)
  #Programming Language
  #Language


  v = list('OSS Title' = oss, 'Average Rating' = avg_rat, 'Description' = desc, 'Last Update' = last_update,
           'Number of Ratings' = num_rat, 'Weekly Downloads' = week_down, 'Project Type' = is_enterpise,
           'Category 1' = category[1],'Category 2' = category[2], 'Category 3' = category[3],
           'Date registered' = date_registered, 'Authors' = authors)
  return(data.frame(v, stringsAsFactors = F))
}
