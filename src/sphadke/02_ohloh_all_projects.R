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
project_ids <- all_random_project_ids[i]

## Table 'project': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

project <- matrix(NA, *, 33)
colnames(project) <- c("project_url_id", "project_name", "project_id", "created_at", "updated_at", "description", "homepage_url", "download_url", "url_name",
                       "user_count", "average_rating", "rating_count", "review_count",
                       "analysis_id", "analysis_url", "last_analysis_update", "last_source_code_access", "ohloh_first_month_of_analysis", "ohloh_latest_month_of_analysis",
                       "twelve_month_contributor_count", "total_contributor_count", "twelve_month_commit_count", "total_commit_count", "total_code_lines", "main_language",
                       "possible_urls", "ohloh_url", "factoids", "tags", "licenses",
                       "languages", "language_percentages", "activity_index")

for(i in 1:nrow(project)){
  contents <- api_q(project_paths[i], "", oh_key_old)

  if(status_code(contents) == 200){
    info <- content(contents)

    project[i,1] <- project_ids[i]
    project[i,2] <- xml_node(info, 'name') %>% html_text
    project[i,3] <- xml_node(info, 'id') %>% html_text() #unique ID for the project
    project[i,4] <- xml_node(info, 'created_at') %>% html_text() #project created at
    project[i,5] <- xml_node(info, 'updated_at') %>% html_text() #last updated at
    project[i,6] <- xml_node(info, 'description') %>% html_text() #Project description
    project[i,7] <- xml_node(info, 'homepage_url') %>% html_text() #homepage URL
    project[i,8] <- xml_node(info, 'download_url') %>% html_text() #download URL
    project[i,9] <- xml_node(info, 'url_name') %>% html_text() #URL name for ohloh URL

    project[i,10] <- xml_node(info, 'user_count') %>% html_text() #i use this
    project[i,11] <- xml_node(info, 'average_rating') %>% html_text()
    project[i,12] <- xml_node(info, 'rating_count') %>% html_text()
    project[i,13] <- xml_node(info, 'review_count') %>% html_text()

    project[i,14] <- xml_node(info, 'analysis_id') %>% html_text()
    project[i,15] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[2] #url for analysis in XML
    project[i,16] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[4] #last update for analysis
    project[i,17] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[5] #last time SCS was accessed for analysis
    project[i,18] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[6] #first month for which ohloh has monthly historical stats
    project[i,19] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[7] #last month for which ohloh has monthly historical stats; mostly current month
    project[i,20] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[8] #twelve month contributor count
    project[i,21] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[9] #total contributor count
    project[i,22] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[10] #twelve month commit count
    project[i,23] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[11] #total month commit count
    project[i,24] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[12] #total code lines
    project[i,25] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[16] #main language

    project[i,26] <- xml_nodes(info, 'url') %>% html_text() %>% paste(collapse = ";")
    project[i,27] <- xml_node(info, 'html_url') %>% html_text()

    project[i,28] <- paste((xml_nodes(info, 'factoid') %>% xml_attr('type')), collapse = ";") #factoid

    # project[i,] <- (xml_nodes(info, 'factoid') %>% xml_text())[1] %>% str_trim() #FactoidAgeVeryOld
    # project[i,] <- (xml_nodes(info, 'factoid') %>% xml_text())[2] %>% str_trim() #FactoidTeamSizeVeryLarge
    # project[i,] <- (xml_nodes(info, 'factoid') %>% xml_text())[3] %>% str_trim() #FactoidCommentsAverage
    # project[i,] <- (xml_nodes(info, 'factoid') %>% xml_text())[4] %>% str_trim() #FactoidActivityStable

    project[i,29] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
    project[i,30] <- paste(unlist((xml_node(info, 'licenses') %>% html_text() %>% str_split(pattern = 'gpl'))), collapse = ";")
    project[i,31] <- xml_children(xml_nodes(info, 'languages')) %>% html_text() %>% str_trim() %>% paste(collapse = ";")
    project[i,32] <- xml_children(xml_nodes(info, 'languages')) %>% xml_attr('percentage') %>% paste(collapse = ';')

    project[i,33] <- xml_node(info, 'project_activity_index') %>% html_text()

    # (xml_nodes(info, 'description') %>% html_text())[2] #project activity index description; comes with the index earlier
    # xml_nodes(info, 'links') %>% html_text()
  } else {
    project[i,1] <- project_ids[i]
  }
  print(i)
}


# Save the table
# write.csv(as.data.frame(project), file = "~/git/oss/data/oss/original/openhub/all_projects_table.csv")
# check <- read.csv("~/git/oss/data/oss/original/openhub/all_projects_table.csv")


