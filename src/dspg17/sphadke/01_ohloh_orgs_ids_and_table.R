##############################
#### Code for OpenHub API ####
##### all orgs; all info #####
##############################

#### Created by: sphadke
#### Creted on: 06/25/2017
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
  info <- #content(
    GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                              path, #page URL
                              page_no, #must be in form "page=n"
                              api_key))#,
                  #as = "parsed")
  return(info)
}


####################
#### Pulling ids
####################
# We create IDs for all orgs
# They go into a path, which then feeds into the API call to then pull table

## Organizations
# org_ids <- vector()
# for (i in 1:85){
#   get_orgs <- api_q("/orgs", paste("page=", i, sep = ""), oh_key)
#   orgs <- content(get_orgs, as = "parsed")
#   ids <- str_split((xml_nodes(orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
#   ids
#   org_ids <- c(org_ids, ids)
# }
#
# org_ids <- unique(org_ids)
# save(org_ids, file = "~/git/oss/data/oss/original/openhub/all_org_ids.R")
load("~/git/oss/data/oss/original/openhub/all_org_ids.R")


####################
#### Pulling the table
####################

## Table 'organization': takes projects
# Creating a path that can directly go into the API function
org_paths <- paste("/", "orgs", "/", org_ids, sep = "")

organization <- matrix(NA, length(org_paths), 16)
colnames(organization) <- c("org_url_id", "org_name", "created_date", "type",
                            "portfolio_projects_count", "portfolio_projects",
                            "affiliators", "affiliators_committing_to_portfolio_projects",
                            "affiliator_commits_to_portfolio_projects", "affiliators_commiting_projects",
                            "outside_committers", "outside_committers_commits", "projects_having_outside_commits",
                            "outside_projects", "outside_projects_commits", "affiliators_committing_to_outside_projects")

# The info we need
for(i in 1:nrow(organization)){
  contents <- api_q(org_paths[i], "", oh_key)

  if(status_code(contents) == 200){
    info <- content(contents, as = "parsed")

    organization[i,1] <- org_ids[i]
    organization[i,2] <- xml_node(info, 'name') %>% html_text()
    organization[i,3] <- xml_nodes(info, 'created_at') %>% html_text()
    organization[i,4] <- xml_nodes(info, 'type') %>% html_text()

    organization[i,5] <- xml_contents(xml_nodes(info, 'portfolio_projects'))[1] %>% html_text()
    organization[i,6] <- xml_nodes(xml_nodes(info, 'portfolio_projects'), "name") %>% html_text() %>% paste(collapse = ';')

    organization[i,7] <- xml_nodes(info, 'affiliators') %>% html_text()
    organization[i,8] <- xml_nodes(info, 'affiliators_committing_to_portfolio_projects') %>% html_text()
    organization[i,9] <- xml_nodes(info, 'affiliator_commits_to_portfolio_projects') %>% html_text()
    organization[i,10] <- xml_nodes(info, 'affiliators_commiting_projects') %>% html_text()

    organization[i,11] <- xml_nodes(info, 'outside_committers') %>% html_text()
    organization[i,12] <- xml_nodes(info, 'outside_committers_commits') %>% html_text()
    organization[i,13] <- xml_nodes(info, 'projects_having_outside_commits') %>% html_text()

    organization[i,14] <- xml_nodes(info, 'outside_projects') %>% html_text()
    organization[i,15] <- xml_nodes(info, 'outside_projects_commits') %>% html_text()
    organization[i,16] <- xml_nodes(info, 'affiliators_committing_to_outside_projects') %>% html_text()
  } else {
    organization[i,1] <- org_ids[i]
  }
  print(i)
}

# Save the table
#save(organization, file = "~/git/oss/output/openhub/sample_of_10/org_table.R")
write.csv(as.data.frame(organization), file = "~/git/oss/data/oss/original/openhub/organizations/all_orgs_table.csv")
check <- read.csv("~/git/oss/data/oss/original/openhub/organizations/all_orgs_table.csv")

