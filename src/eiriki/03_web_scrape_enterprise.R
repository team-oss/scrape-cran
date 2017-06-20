#this will handle the case that a project on Sourceforge is an enterprise, which we have to
#scrape differently
library(RCurl)
library(xml2)
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
    html_nodes('#breadcrumbs li+ li span') %>%
    html_text() %>%
    str_trim()

  #This function is only called if the project is an enterprise so disntinguish that it's an enterprise
  is_enterpise <- "Enterprise"

  #Get the date registered
  date_registered <- SFLink %>%
    html_node('.project-info:nth-child(2) .content') %>%
    html_text() %>%
    str_trim()

  #authors is NA for enterprise, this will do nothing
  authors <- NA
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
           'Category 1' = category[1], 'Category 2' = category[2], 'Category 3' = category[3],
           'Date registered' = date_registered, 'Authors' = authors)
  return(data.frame(v, stringsAsFactors = F))
}
