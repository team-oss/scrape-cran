##############################################
#### Code for OpenHub API: users/accounts ####
##############################################
## Total users as of 07/09/2017: 291906

#### Created by: sphadke
#### Creted on: 07/09/2017
#### Last edited on: 07/09/2017


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
library(sdalr)
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
# We create IDs for users/accounts
# They go into a path, which then feeds into the API call to then pull table

# Run it once per key on 1000 pages
oh_key <- oh_key_sp

##Accounts
account_ids <- vector()
for (i in 1:981){
  get_orgs <- api_q("/accounts", paste("page=", i, sep = ""), oh_key)
  orgs <- content(get_orgs, as = "parsed")
  ids <- str_split((xml_nodes(orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  print(i)
  account_ids <- c(account_ids, ids)
}


# Run it once per key on 1000 pages
oh_key <- oh_key_ssp

##Accounts
for (i in 982:1981){
  get_orgs <- api_q("/accounts", paste("page=", i, sep = ""), oh_key)
  orgs <- content(get_orgs, as = "parsed")
  ids <- str_split((xml_nodes(orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  print(i)
  account_ids <- c(account_ids, ids)
}


# Run it once per key on 1000 pages
oh_key <- oh_key_zh

##Accounts
for (i in 1982:2981){
  get_orgs <- api_q("/accounts", paste("page=", i, sep = ""), oh_key)
  orgs <- content(get_orgs, as = "parsed")
  ids <- str_split((xml_nodes(orgs, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  print(i)
  account_ids <- c(account_ids, ids)
}

account_ids <- unique(account_ids)

## Save the file
save(account_ids, file = "~/git/oss/data/oss/original/openhub/users/29810_account_ids.RData")



