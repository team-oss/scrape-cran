####################################
#### OpenHub API: account table ####
####################################
# This code to pull account tables can be used
# for relevant accounts and/or random accounts

#### Created by: sphadke
#### Creted on: 07/17/2017
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


# Get account IDs
load("~/git/oss/data/oss/original/openhub/users/29810_account_ids.RData")


####################
#### Pulling the table
####################

## Table 'account': takes accounts
# Creating a path that can directly go into the API function
account_paths <- paste("/", "accounts", "/", account_ids, sep = "")

account <- matrix(NA, *, 20)
colnames(account) <- c("account_url_id", "account_id", "account_name", "created_at", "updated_at",
                       "about", "homepage_url", "twitter_handle", "email",
                       "location", "country_code", "latitude", "longitude",
                       "posts_count", "kudo_score",
                       "languages", "experience_months", "total_commits", "total_lines_changed", "comment_ratio")

for(i in 1:nrow(account)){
  contents <- api_q(account_paths[i], "", oh_key_old)

  if(status_code(contents) == 200){
    info <- content(contents)

    account[i,1] <- account_ids[i]
    account[i,2] <- xml_node(info, 'id') %>% html_text() #unique ID for the account
    account[i,3] <- xml_node(info, 'name') %>% html_text()
    account[i,4] <- xml_node(info, 'created_at') %>% html_text() #account created at
    account[i,5] <- xml_node(info, 'updated_at') %>% html_text() #last updated at
    account[i,6] <- xml_node(info, 'about') %>% html_text() #account description
    account[i,7] <- xml_node(info, 'homepage_url') %>% html_text() #homepage URL
    account[i,8] <- xml_node(info, 'twitter_account') %>% html_text() #twitter handle
    account[i,9] <- xml_node(info, 'email_sha1') %>% html_text() #The SHA1 hex digest of the account email address

    account[i,10] <- xml_node(info, 'location') %>% html_text()
    account[i,11] <- xml_node(info, 'country_code') %>% html_text()
    account[i,12] <- xml_node(info, 'latitude') %>% html_text()
    account[i,13] <- xml_node(info, 'longitude') %>% html_text()

    account[i,14] <- xml_node(info, 'posts_count') %>% html_text()
    account[i,15] <- xml_node(info, 'kudo_score') %>% html_text()
    num_lang <- length(xml_nodes(info, 'experience_months') %>% html_text())
    account[i,16] <- (xml_nodes(info, 'name') %>% html_text())[2:(num_lang+1)] %>% paste(collapse = ";")
    account[i,17] <- xml_nodes(info, 'experience_months') %>% html_text() %>% paste(collapse = ";")
    account[i,18] <- xml_nodes(info, 'total_commits') %>% html_text() %>% paste(collapse = ";")
    account[i,19] <- xml_nodes(info, 'total_lines_changed') %>% html_text() %>% paste(collapse = ";")
    account[i,20] <- xml_nodes(info, 'comment_ratio') %>% html_text() %>% paste(collapse = ";")
  } else {
    account[i,1] <- account_ids[i]
  }
  print(i)
}


# Save the table
# write.csv(as.data.frame(account), file = "~/git/oss/data/oss/original/openhub/all_accounts_table.csv")
# check <- read.csv("~/git/oss/data/oss/original/openhub/all_accounts_table.csv")

