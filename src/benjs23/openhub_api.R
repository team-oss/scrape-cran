########################################################################
##### Code to pull info from OpenHub API: assumes known inputs for #####
#### account_id, project_id, org_name, analysis_id, or org_url_name ####
########################################################################

#### Created by: sphadke, benjs23
#### Creted on: 06/15/2017
#### Last edited on: 06/21/2017


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

# API keys
# Alex's key
oh_key <- "d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1"

# Ben's key
oh_key_bjs <- "ea13e69a9fe006292249cffce39e96a5781088724a61cda6dba72fd9e71ecc06"

# Sayali's key
oh_key_sp <- "f4b26446fe7946dc11e35e1e34e99aa9c2362b4294ce5d9799913fb6edcb7487"

# Function to create the correct path, get xml from it, and parse out the info
api_q <- function(path, page_no, api_key){
  info <- content(GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                              path, #page URL
                              page_no, #must be in form "page=n"
                              api_key)),
                  as = "parsed")
  return(info)
}


####################
#### Testing: code at the end
####################


####################
#### Pulling ids
####################
# We create IDs for a set of 10 users, projects, and organizations
# They go into a path, which then feeds into the API call to then pull tables

## Users
ten_users <- api_q("/accounts", "page=1", oh_key)
user_ids <- xml_nodes(ten_users, 'login') %>% html_text()
save(user_ids, file = "~/git/oss/output/OpenHub/Sample_of_10/ten_user_ids.R")

## Projects
ten_projects <- api_q("/projects", "page=1", oh_key)
project_ids <- str_split((xml_nodes(ten_projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
save(project_ids, file = "~/git/oss/output/OpenHub/Sample_of_10/ten_project_ids.R")

## Organizations
ten_orgs <- api_q("/orgs", "page=1", oh_key)
org_ids <- str_split((xml_nodes(ten_orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
save(org_ids, file = "~/git/oss/output/OpenHub/Sample_of_10/ten_org_ids.R")




########################################################
########################################################
###   Loop to return all projects and write to text file
########################################################
path = "/projects"
projectMasterID <-NULL
projects <- NULL
n = 67000 #estimate of number of project pages
fileConn1<-file("openHubProjectMasterID.txt")
fileConn2<-file("openHubProjectMaster.txt")

for (pages in c(1:n)){
  projectsTemp <-  content(GET(sprintf('https://www.openhub.net%s.xml?page=%s&api_key=%s',
                                        path,
                                        pages,
                                        oh_key)))
  
  ######this code still needs to append all project info gathered in projectsTemp to object 'projects'#######
  
  projectID <- str_split((xml_nodes(projectsTemp, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  
  projectMasterID <- c(projectMasterID, projectID)
  
  write(projectMasterID, fileConn1, append = TRUE)
  write(projects, fileConn2, append = TRUE) ###cannot write list to txt file
}
close(fileConn1)
close(fileConn2)

###############################




####################
#### Pulling tables
####################

####
#### All tables that take users as inputs
####

## Table 'account': takes users
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, sep = "")

# Should include user_name and country_code
account <- matrix(NA, 10, 2)
colnames(account) <- c("user_name", "country_code")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i], "", oh_key)
  account[i,1] <- (xml_nodes(info, 'name') %>% html_text())[1]
  account[i,2] <- xml_nodes(info, 'country_code') %>% html_text()
}


## Table 'kudo': takes users
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, "/", "kudos", sep = "")

# Should include user_name and country_code
kudo <- matrix(NA, 10, 6)
colnames(kudo) <- c("user_name", "created_at", "sender_account_name", "receiver_account_name", "project_name", "contributor_name")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i], "", oh_key)
  kudo[i,1] <- user_ids[i]
  kudo[i,2] <- xml_nodes(info, 'created_at') %>% html_text() %>% paste(collapse = ';')
  kudo[i,3] <- xml_nodes(info, 'sender_account_name') %>% html_text() %>% paste(collapse = ';')
  kudo[i,4] <- unique(xml_nodes(info, 'receiver_account_name') %>% html_text()) %>% paste(collapse = ';')
  kudo[i,5] <- xml_nodes(info, 'project_name') %>% html_text() %>% paste(collapse = ';')
  kudo[i,6] <- xml_nodes(info, 'contributor_name') %>% html_text() %>% paste(collapse = ';')
}


## Table 'positions': takes users
# Creating a path that can directly go into the API function
user_paths <- paste("/", "accounts", "/", user_ids, "/", "positions", sep = "")

# Should include user_name and country_code
positions <- matrix(NA, 10, 7)
colnames(positions) <- c("user_name", "title", "organization", "updated_at", "started_at", "ended_at", "commits")

# The info we need
for(i in 1:nrow(account)){
  info <- api_q(user_paths[i], "", oh_key)
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
save(user_table, file = "~/git/oss/output/OpenHub/Sample_of_10/user_table.R")



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



# Creating a path that can directly go into the API function
org_paths <- paste("/", "orgs", "/", org_ids, sep = "")
