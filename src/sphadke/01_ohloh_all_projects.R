#######################
##### OpenHub API #####
#### projects info ####
#######################

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


####################
#### Pulling ids
####################
# We create IDs for as many projects as possible
# They go into a path, which then feeds into the API call to then pull table

## Organizations
project_ids <- vector()
k <- #number of pages possible on the given API key
for (i in 1:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_old)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
}

project_ids <- unique(project_ids)
# save(org_ids, file = "~/git/oss/data/oss/original/openhub/all_project_ids.R")
load("~/git/oss/data/oss/original/openhub/all_project_ids.R")


####################
#### Pulling the table
####################

## Table 'project': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

project <- matrix(NA, NEED_TO_INPUT, 4)
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


# Save the table
write.csv(as.data.frame(project), file = "~/git/oss/data/oss/original/openhub/all_projects_table.csv")
check <- read.csv("~/git/oss/data/oss/original/openhub/all_projects_table.csv")


