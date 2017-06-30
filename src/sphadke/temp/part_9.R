###################################################
#### OpenHub API: random sample of project IDs ####
###################################################
# Don't edit without checking-in with Sayali

#### Created by: sphadke
#### Authors: sphadke, benjs23
#### Creted on: 06/29/2017
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

## API keys
source("~/git/oss/src/sphadke/00_ohloh_keys.R")


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

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/sample_pages_to_pull.RData")

## Projects

pulling_random_project_ids <- function(j, k, key){
  random_project_ids <- c()
  #j: start page index
  #k: end page index
  for (i in j:k){
    page <- pages_to_pull[i]
    get_projects <- api_q("/projects", paste("page=", page, sep = ""), key)
    projects <- content(get_projects, as = "parsed")
    ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
    random_project_ids <- c(random_project_ids, ids)
    print(i)
  }
  return(random_project_ids)
}

####
#### Part 9
####

random_project_ids <- pulling_random_project_ids(6401, 7200, oh_key_cm)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_9.RData")



