#####################
#### OpenHub API ####
#### project IDS ####
#####################

#### Created by: sphadke
#### Creted on: 06/27/2017
#### Last edited on: 06/27/2017


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

##
## API keys
##
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
load("~/git/oss/data/oss/original/openhub/projects/all_project_ids_1.R")


####################
#### Pulling the table
####################

# Choose which IDs, or how many of the IDs to use for the session
project_ids <- "firefox"

## Table 'project': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

project <- matrix(NA, 1, 5)
colnames(project) <- c("project_url_id", "project_name", "user_count", "average_rating", "tags")

for(i in 1:nrow(project)){
  contents <- api_q(project_paths[i], "", oh_key)

  if(status_code(contents) == 200){
    info <- content(contents)

    project[i,1] <- project_ids[i]
    project[i,2] <- xml_node(info, 'name') %>% html_text
    project[i,3] <- xml_nodes(info, 'user_count') %>% html_text()
    project[i,4] <- xml_nodes(info, 'average_rating') %>% html_text()
    project[i,5] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
  } else {
    project[i,1] <- project_ids[i]
  }
  print(i)
}

#created_at
#updated_at
#user_count
#average_rating
#rating_count
#tags
#language
#project_activity_index


# Save the table
write.csv(as.data.frame(project), file = "~/git/oss/data/oss/original/openhub/all_projects_table.csv")
check <- read.csv("~/git/oss/data/oss/original/openhub/all_projects_table.csv")


