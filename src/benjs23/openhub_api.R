########################################################################
##### Code to pull info from OpenHub API: assumes known inputs for #####
#### account_id, project_id, org_name, analysis_id, or org_url_name ####
########################################################################

#### Created by: sphadke, benjs23
#### Creted on: 06/15/2017
#### Last edited on: 06/20/2017


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

# API key
# Still using the one from last year
# Sayali needs to request her own!
oh_key <- "d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1"

# Function to create the correct path, get xml from it, and parse out the info
api_q <- function(path){
  info <- content(GET(sprintf('https://www.openhub.net%s.xml?api_key=%s',
                              path,
                              oh_key)),
                  as = "parsed")
  return(info)
}


# ####################
# #### Testing
# ####################
# proj_path <- '/projects/firefox'
# user_path <- '/accounts/Stefan'
# org_path <- '/orgs/mozilla'
# 
# proj <- api_q(proj_path)
# xml_nodes(proj, 'name')
# xml_nodes(proj, 'tag')
# rvest::xml_nodes(proj, 'tag') %>% rvest::html_text()
# rvest::xml_nodes(proj, 'tag') %>% rvest::html_text() %>% paste(collapse = ';')
# 
# user <- api_q(user_path)
# xml_nodes(user, 'country_code') %>% html_text()
# (xml_nodes(user, 'name') %>% html_text())[1]
# xml_nodes(user, 'id') %>% html_text()
# 
# all_projs <- api_q("/projects")
# xml_nodes(all_projs, 'name') %>% html_text()
# 
# all_accounts <- api_q("/accounts")
# xml_nodes(all_accounts, 'login') %>% html_text()
# 
# org <- api_q(org_path)
# xml_nodes(org, 'name')


####################
#### Pulling tables
####################

####
#### Setup
####

# We create IDs for a set of 10 users, projects, and organizations
# They go into a path, which then feeds into the API call to then pull tables

## Users
# Pulling account IDs
all_users <- api_q("/accounts")
user_ids <- xml_nodes(all_users, 'login') %>% html_text()

## Projects
# Pulling project IDs
# Next two lines not clean. This is how we get page 2
url <- "https://www.openhub.net/projects.xml?page=2&api_key=d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1"
info <- content(GET(url), as="parsed")

all_projects <- api_q("/projects")
project_ids <- str_split((xml_nodes(all_projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]

## Organizations
# This gives only 10. There is an easy way to pull more
# https://github.com/blackducksoftware/ohloh_api/blob/master/reference/organization-collection.md

# Pulling org IDs
all_orgs <- api_q("/orgs")
org_ids <- str_split((xml_nodes(all_orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]


####
#### Let's get them tables!
#### Start with all projects that take users as inputs
####

##
## Table 'account': takes users
##
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, sep = "")

# Should include user_name and country_code
account <- matrix(NA, 10, 2)
colnames(account) <- c("user_name", "country_code")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i])
  account[i,1] <- (xml_nodes(info, 'name') %>% html_text())[1]
  account[i,2] <- xml_nodes(info, 'country_code') %>% html_text()
}


##
## Table 'kudo': takes users
##
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, "/", "kudos", sep = "")

# Should include user_name and country_code
kudo <- matrix(NA, 10, 6)
colnames(kudo) <- c("user_name", "created_at", "sender_account_name", "receiver_account_name", "project_name", "contributor_name")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i])
  kudo[i,1] <- user_ids[i]
  kudo[i,2] <- xml_nodes(info, 'created_at') %>% html_text() %>% paste(collapse = ';')
  kudo[i,3] <- xml_nodes(info, 'sender_account_name') %>% html_text() %>% paste(collapse = ';')
  kudo[i,4] <- unique(xml_nodes(info, 'receiver_account_name') %>% html_text()) %>% paste(collapse = ';')
  kudo[i,5] <- xml_nodes(info, 'project_name') %>% html_text() %>% paste(collapse = ';')
  kudo[i,6] <- xml_nodes(info, 'contributor_name') %>% html_text() %>% paste(collapse = ';')
}


##
## Table 'positions': takes users
##
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, "/", "positions", sep = "")

# Should include user_name and country_code
positions <- matrix(NA, 10, 7)
colnames(positions) <- c("user_name", "title", "organization", "updated_at", "started_at", "ended_at", "commits")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i])
  positions[i,1] <- user_ids[i]
  positions[i,2] <- xml_nodes(info, 'title') %>% html_text() %>% paste(collapse = ';')
  positions[i,3] <- xml_nodes(info, 'organization') %>% html_text() %>% paste(collapse = ';')
  positions[i,4] <- xml_nodes(info, 'updated_at') %>% html_text() %>% paste(collapse = ';')
  positions[i,5] <- xml_nodes(info, 'started_at') %>% html_text() %>% paste(collapse = ';')
  positions[i,6] <- xml_nodes(info, 'ended_at') %>% html_text() %>% paste(collapse = ';')
  positions[i,7] <- xml_nodes(info, 'commits') %>% html_text() %>% paste(collapse = ';')
}


##
## Merge all user tables
##
user_table <- cbind(account, kudo, positions)




##
## Table 'activityfact': takes projects
##
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

activity_fact <- matrix(NA, 10, 10)
colnames(activity_fact) <- c("project_name", "month", "code_added", "code_removed", "comments_added", "comments_removed", "blanks_added", "blanks_removed", "commits", "contributors")

# The info we need
for(i in 1:nrow(activity_fact)){
  info <- api_q(project_paths[i])
  account[i,1] <- (xml_nodes(info, 'name') %>% html_text())[1]
  account[i,2] <- xml_nodes(info, 'code') %>% html_text()
}




# Creating a path that can directly go into the API function
org_paths <- paste("/", "orgs", "/", org_ids, sep = "")
