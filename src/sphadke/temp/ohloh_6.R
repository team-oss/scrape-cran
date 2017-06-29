#####################
#### OpenHub API ####
#### project IDs ####
#####################
# Don't edit without checking-in with Sayali

#### Created by: sphadke
#### Authors: sphadke, benjs23
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
api_keys <- grep("oh_key", ls(), value = TRUE)

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
# project_ids <- vector()
# k <- 4400#number of pages possible on the given API key
# for (i in 3401:k){
#   get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_sep)
#   projects <- content(get_projects, as = "parsed")
#   ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
#   ids
#   project_ids <- c(project_ids, ids)
#   print(i)
# }
#
# project_ids <- unique(project_ids)
# save(project_ids, file = "~/git/oss/data/oss/original/openhub/all_project_ids_5.R")
# load("~/git/oss/data/oss/original/openhub/all_project_ids_3.R")


####################
#### Temp code: this was the lazy code Sayali wrote to run org_ids pull in the background
#### File needs to be cleaned to remove this
####################

####
#### Part 6
####

project_ids <- vector()
k <- 5395#number of pages possible on the given API key
for (i in 4401:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_zh)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/all_project_ids_6.R")



