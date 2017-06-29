########################################################################
##### Code to pull info from OpenHub API: assumes known inputs for #####
#### account_id, project_id, org_name, analysis_id, or org_url_name ####
########################################################################

#### Created by: sphadke, benjs23
#### Creted on: 06/15/2017
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

# API keys
source("~/git/oss/src/sphadke/00_ohloh_keys.R")

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

# ## Users
# ten_users <- api_q("/accounts", "page=1", oh_key)
# user_ids <- xml_nodes(ten_users, 'login') %>% html_text()
# save(user_ids, file = "~/git/oss/output/openhub/sample_of_10/ten_user_ids.R")
load("~/git/oss/output/openhub/sample_of_10/ten_user_ids.R")

# ## Projects
# ten_projects <- api_q("/projects", "page=1", oh_key)
# project_ids <- str_split((xml_nodes(ten_projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
# save(project_ids, file = "~/git/oss/output/openhub/sample_of_10/ten_project_ids.R")
load("~/git/oss/output/openhub/sample_of_10/ten_project_ids.R")

# ## Organizations
# ten_orgs <- api_q("/orgs", "page=1", oh_key)
# org_ids <- str_split((xml_nodes(ten_orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
# save(org_ids, file = "~/git/oss/output/openhub/sample_of_10/ten_org_ids.R")
load("~/git/oss/output/openhub/sample_of_10/ten_org_ids.R")




############################################################
############################################################
###  Loop to return all projects and write to text file  ###
############################################################
############################################################
path = "/projects"
projectMasterID <-NULL
projects <- NULL
n = 2 #estimate of number of project pages
fileConn1<-file("openHubProjectMasterID.txt")

for (pages in c(1:n)){
  projectsTemp <-  (content(GET(sprintf('https://www.openhub.net%s.xml?page=%s&api_key=%s',
                                       path,
                                       pages,
                                       oh_key_bjs))))
  projectsParsed <- xmlParse(projectsTemp)

  projects <- append(projects, projectsParsed)

  projectID <- str_split((xml_nodes(projectsTemp, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]

  projectMasterID <- c(projectMasterID, projectID)

  write(projectMasterID, fileConn1, append = TRUE)
  #write(projects, fileConn2, append = TRUE)
  #projects <- append(projects, xmlToList(projectsTemp))
  ##writeLines(projects, )

}
sink("~/git/oss/data/oss/original/projects.txt") ###HOW TO WRITE ENTIRE CONTENTS OF A NESTED LIST TO A TEXT FILE?????
print(projects)
sink()
close(fileConn1)


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


# # Table: 'stack: takes users: code under development: at the end

## Merge all user tables
user_table <- cbind(account, kudo, positions)
#save(user_table, file = "~/git/oss/output/openhub/sample_of_10/user_table.R")
#write.csv(user_table, file = "~/git/oss/output/openhub/sample_of_10/user_table.csv")

####
#### All tables that take projects as inputs
####

## Table 'activity_fact': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, "/analyses/latest/activity_facts", sep = "")

activity_fact <- matrix(NA, 10, 10)
colnames(activity_fact) <- c("project_name", "date", "code_added", "code_removed", "comments_added", "comments_removed", "blanks_added", "blanks_removed", "commits", "contributors")

# The info we need
for(i in 1:nrow(activity_fact)){
  info <- api_q(project_paths[i], "", oh_key)
  activity_fact[i,1] <- project_ids[i]
  activity_fact[i,2] <- xml_nodes(info, 'month') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,3] <- xml_nodes(info, 'code_added') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,4] <- xml_nodes(info, 'code_removed') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,5] <- xml_nodes(info, 'comments_added') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,6] <- xml_nodes(info, 'comments_removed') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,7] <- xml_nodes(info, 'blanks_added') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,8] <- xml_nodes(info, 'blanks_removed') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,9] <- xml_nodes(info, 'commits') %>% html_text() %>% paste(collapse = ';')
  activity_fact[i,10] <- xml_nodes(info, 'contributors') %>% html_text() %>% paste(collapse = ';')
}


## Table 'activity': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, "/analyses/latest", sep = "")

activity <- matrix(NA, 10, 10)
colnames(activity) <- c("project_name", "update_at", "min_month", "max_month", "twelve_month_contributor_count", "total_contributor_count", "twelve_month_commit_count", "total_commit_count", "total_code_lines", "main_language_name")

# The info we need
for(i in 1:nrow(activity)){
  info <- api_q(project_paths[i], "", oh_key)
  activity[i,1] <- project_ids[i]
  activity[i,2] <- xml_nodes(info, 'updated_at') %>% html_text() %>% paste(collapse = ';')
  activity[i,3] <- xml_nodes(info, 'min_month') %>% html_text()
  activity[i,4] <- xml_nodes(info, 'max_month') %>% html_text()
  activity[i,5] <- xml_nodes(info, 'twelve_month_contributor_count') %>% html_text()
  activity[i,6] <- xml_nodes(info, 'total_contributor_count') %>% html_text()
  activity[i,7] <- xml_nodes(info, 'twelve_month_commit_count') %>% html_text()
  activity[i,8] <- xml_nodes(info, 'total_commit_count') %>% html_text()
  activity[i,9] <- xml_nodes(info, 'total_code_lines') %>% html_text()
  activity[i,10] <- xml_nodes(info, 'main_language_name') %>% html_text()
}


## Table 'contributorfact': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, "/", "contributors", sep = "")

contributorfact <- matrix(NA, 10, 9)
colnames(contributorfact) <- c("project_name", "contributor_name", "account_name", "primary_language_nice_name", "comment_ratio", "first_commit_time", "last_commit_time", "man_months", "commits")

for(i in 1:nrow(contributorfact)){
  info <- api_q(project_paths[i], "", oh_key)
  contributorfact[i,1] <- project_ids[i]
  contributorfact[i,2] <- xml_nodes(info, 'contributor_name') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,3] <- xml_nodes(info, 'account_name') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,4] <- xml_nodes(info, 'primary_language_nice_name') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,5] <- xml_nodes(info, 'comment_ratio') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,6] <- xml_nodes(info, 'first_commit_time') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,7] <- xml_nodes(info, 'last_commit_time') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,8] <- xml_nodes(info, 'man_months') %>% html_text() %>% paste(collapse = ';')
  contributorfact[i,9] <- xml_nodes(info, 'commits') %>% html_text() %>% paste(collapse = ';')
}


## Table 'project': takes projects
# Creating a path that can directly go into the API function
project_paths <- paste("/", "projects", "/", project_ids, sep = "")

project <- matrix(NA, 10, 4)
colnames(project) <- c("project_name", "user_count", "average_rating", "tags")

for(i in 1:nrow(project)){
  info <- api_q(project_paths[i], "", oh_key)
  project[i,1] <- project_ids[i]
  project[i,2] <- xml_nodes(info, 'user_count') %>% html_text()
  project[i,3] <- xml_nodes(info, 'average_rating') %>% html_text()
  project[i,4] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
}


# Table: 'stack: takes project: code under development: at the end

## Merge all project tables
project_table <- cbind(project, contributorfact, activity, activity_fact)
# save(user_table, file = "~/git/oss/output/openhub/sample_of_10/project_table.R")
# write.csv(project_table, file = "~/git/oss/output/openhub/sample_of_10/project_table.csv")


####
#### All tables that take projects as inputs
####

## Table 'activity_fact': takes projects
# Creating a path that can directly go into the API function
org_paths <- paste("/", "orgs", "/", org_ids, sep = "")

organization <- matrix(NA, 10, 15)
colnames(organization) <- c("org_name", "created_date", "type",
                            "portfolio_projects_count", "portfolio_projects",
                            "affiliators", "affiliators_committing_to_portfolio_projects",
                            "affiliator_commits_to_portfolio_projects", "affiliators_commiting_projects",
                            "outside_committers", "outside_committers_commits", "projects_having_outside_commits",
                            "outside_projects", "outside_projects_commits", "affiliators_committing_to_outside_projects")

# The info we need
for(i in 1:nrow(organization)){
  info <- api_q(org_paths[i], "", oh_key)
  organization[i,1] <- org_ids[i]
  organization[i,2] <- xml_nodes(info, 'created_at') %>% html_text()
  organization[i,3] <- xml_nodes(info, 'type') %>% html_text()

  organization[i,4] <- xml_contents(xml_nodes(info, 'portfolio_projects'))[1] %>% html_text()
  organization[i,5] <- xml_nodes(xml_nodes(info, 'portfolio_projects'), "name") %>% html_text() %>% paste(collapse = ';')

  organization[i,6] <- xml_nodes(info, 'affiliators') %>% html_text() #Same as affiliated committers
  organization[i,7] <- xml_nodes(info, 'affiliators_committing_to_portfolio_projects') %>% html_text()
  organization[i,8] <- xml_nodes(info, 'affiliator_commits_to_portfolio_projects') %>% html_text()
  organization[i,9] <- xml_nodes(info, 'affiliators_commiting_projects') %>% html_text()

  organization[i,10] <- xml_nodes(info, 'outside_committers') %>% html_text()
  organization[i,11] <- xml_nodes(info, 'outside_committers_commits') %>% html_text()
  organization[i,12] <- xml_nodes(info, 'projects_having_outside_commits') %>% html_text()

  organization[i,13] <- xml_nodes(info, 'outside_projects') %>% html_text()
  organization[i,14] <- xml_nodes(info, 'outside_projects_commits') %>% html_text()
  organization[i,15] <- xml_nodes(info, 'affiliators_committing_to_outside_projects') %>% html_text()
}

# Save the table
# save(organization, file = "~/git/oss/output/openhub/sample_of_10/org_table.R")
# write.csv(organization, file = "~/git/oss/output/openhub/sample_of_10/org_table.csv")




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


####
#### Stack codes: on hold
####
# # Table: 'stack: takes project
# # Creating a path that can directly go into the API function
# project_paths <- paste("/", "projects", "/", project_ids, "/", "stacks", sep = "")
#
# project <- matrix(NA, 10, 4)
# colnames(project) <- c("project_name", "user_count", "average_rating", "tags")
#
# for(i in 1:nrow(project)){
#   info <- api_q(project_paths[i], "", oh_key)
#   project[i,1] <- project_ids[i]
#   project[i,2] <- xml_nodes(info, 'project_count') %>% html_text()
#   project[i,3] <- xml_nodes(info, 'stack_entries') %>% html_text()
#   project[i,4] <- xml_nodes(info, 'account') %>% html_text()
#   project[i,4] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
# }


# # Table: 'stack: takes users
# # Creating a path that can directly go into the API function
# user_paths <- paste("/", "accounts", "/", user_ids, "/", "stacks", sep = "")
# sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
#         user_paths[i], #page URL
#         "", #must be in form "page=n"
#         oh_key)
# stack <- matrix(NA, 10, 4)
# colnames(project) <- c("user_name", "title", "project_count", "stack_entries", "account")
#
# for(i in 1:nrow(stack)){
#   info <- api_q(user_paths[i], "", oh_key)
#   stack[i,1] <- user_ids[i]
#   stack[i,2] <- xml_nodes(info, 'project_count') %>% html_text()
#   stack[i,3] <- xml_nodes(info, 'average_rating') %>% html_text()
#   stack[i,4] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
#   stack[i,4] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
# }

