####################################
#### OpenHub API: project table ####
####################################
# This code to pull project tables can be used
# for relevant projects and/or random projects

#### Created by: sphadke
#### Creted on: 06/27/2017
#### Last edited on: 06/29/2017


####################
#### Cleanup
####################
rm(list=ls())
gc()
set.seed(312)


####################
#### R Setup
####################
library(httr)
library(plyr)
library(rvest)
library(stringr)
library(XML)


####################
#### Code setup
####################

# Function to pull from openhub
# All thanks to Daniel Chen, and help from https://github.com/r-lib/httr/blob/master/vignettes/api-packages.Rmd and http://bradleyboehmke.github.io/2016/01/scraping-via-apis.html#httr_api

## API keys
source("~/git/oss/src/sphadke/00_ohloh_keys.R")
avail_keys <- length(grep("oh_key", ls()))
avail_keys

# Function to create the correct path, get xml from it
api_q <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                      path, #page URL
                      page_no, #must be in form "page=n"
                      api_key))
  return(info)
}

# Get project IDs
load("~/git/oss/data/oss/original/openhub/projects/relevant/project_ids/all_project_ids_1.R")


####################
#### Pulling the table
####################

# Choose which IDs, or how many of the IDs to use for the session
project_ids <- project_ids[i]

## Table 'project': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

project <- matrix(NA, 1, 5)
colnames(project) <- c("project_url_id", "project_name", "user_count", "average_rating", "tags")

for(i in 1:nrow(project)){
  contents <- api_q(project_paths[i], "", oh_key_)

  if(status_code(contents) == 200){
    info <- content(contents)

    project[i,1] <- project_ids[i]
    project[i,2] <- xml_node(info, 'name') %>% html_text

    xml_node(info, 'id') %>% html_text()
    xml_node(info, 'created_at') %>% html_text()
    xml_node(info, 'updated_at') %>% html_text()
    xml_node(info, 'description') %>% html_text() #Project description
    xml_node(info, 'homepage_url') %>% html_text() #Homepage URL
    xml_node(info, 'download_url') %>% html_text() #Download URL
    xml_node(info, 'url_name') %>% html_text() #URL name
    xml_node(info, 'vanity_name') %>% html_text() #Vanity name

    project[i,3] <- xml_nodes(info, 'user_count') %>% html_text()
    project[i,4] <- xml_nodes(info, 'average_rating') %>% html_text()
    project[i,4] <- xml_nodes(info, 'rating_count') %>% html_text()

    xml_nodes(info, 'analysis_id') %>% html_text()
    xml_contents(xml_node(info, 'analysis')) %>% html_text()
    xml_nodes(info, 'url') %>% html_text()
    xml_nodes(info, 'html_url') %>% html_text()
    xml_nodes(info, 'factoid') %>% html_text()

    project[i,5] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')

    xml_node(info, 'licenses') %>% html_text() %>% paste(collapse = 'gpl')
    xml_children(xml_nodes(info, 'languages')) %>% html_text() %>% stringr::str_trim() %>% paste(collapse = ";")
    xml_children(xml_nodes(info, 'languages')) %>% xml_attr('percentage') %>% paste(collapse = ';')
    xml_nodes(info, 'project_activity_index') %>% html_text()

    # (xml_nodes(info, 'description') %>% html_text())[2] #project activity index description; comes with the index earlier
    # xml_nodes(info, 'links') %>% html_text()
  } else {
    project[i,1] <- project_ids[i]
  }
  print(i)
}


# Save the table
write.csv(as.data.frame(project), file = "~/git/oss/data/oss/original/openhub/all_projects_table.csv")
check <- read.csv("~/git/oss/data/oss/original/openhub/all_projects_table.csv")


