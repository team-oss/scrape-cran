##################################################
#### Automated scraping accounts from OpenHub ####
##################################################
# Saved specifically to work with accounts

### Created by: benjs23
### Created Date: 06/29/2017
### Last edited date: 07/06/2017

####### This code automates the scraping from OpenHub. It loads a list of API keys
####### and takes a function name as input. It automatically runs through every API
####### key, pulls the user specified tables, and tracks what information has been
####### collected.

##
## Setup and clanup
##

library(httr)
library(plyr)
library(rvest)
library(stringr)
library(XML)
library(rio)
library(readr)

rm(list=ls())

#k <- write("k","~/git/oss/data/oss/original/openhub/users/k_index.txt")

k <- read_file("./data/oss/original/openhub/users/k_index.txt")

if(k == "k\n")
{
  k = 0
}else
{
  k = as.integer(str_split(k,"\n", n=1))
}


##
## Setting up API keys
##

# pulls in vector of API keys
source("./src/sphadke/00_ohloh_keys.R")

#puts API keys into a named vector
curr_ls <- ls()
pattern <- '^oh_key_'
match <- grep(pattern = pattern, x = ls())
key_names <- curr_ls[match]
all_keys <- c()

source("./src/sphadke/00_ohloh_keys.R")
## Remove for next run
rm(oh_key_old)
##
curr_ls <- ls()
pattern <- '^oh_key_'
match <- grep(pattern = pattern, x = ls())
key_names <- curr_ls[match]

all_keys <- c()

for (key in key_names) {
  all_keys <- c(all_keys,get(key))
}
names(all_keys) <- key_names
print(all_keys)


##
# Function to create the correct path and get xml format data from it
##
api_q <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                      path, #page URL
                      page_no, #must be in form "page=n"
                      api_key))
  return(info)
}

##
# Get account IDs
##

#This pathway is for the top 29810 most relevant account IDs
load("./data/oss/original/openhub/users/29810_to_79810_account_ids.RData")

loopBreak = FALSE


##
## Setup an empty table
##

account <- matrix(NA, length(account_ids), 20)
colnames(account) <- c("account_url_id", "account_id", "account_name", "created_at", "updated_at",
                       "about", "homepage_url", "twitter_handle", "email",
                       "location", "country_code", "latitude", "longitude",
                       "posts_count", "kudo_score",
                       "languages", "experience_months", "total_commits", "total_lines_changed", "comment_ratio")


##
## Looping through
##

#outer loop runs through the list of every API key
for(j in 1:length(all_keys))
# for(j in 1:17)
  {
  #break out of loop if all of the keys have been used
  if(loopBreak == TRUE)
  {

    break
  }

  #sets current API key
  oh_key <- paste(all_keys[j])

  #creates inner loop index variable to be equal to the first number in the next set of 1000 account IDs
  k = (length(account_ids) - (length(account_ids)-k))

  #loops through the next 1000 account IDs (this is how many calls you're allowed per API key per day)
  for(k in ((k+1):(k+1000)))
  {

    ## Pulling the table from ohloh

    #checks that index k has not exceeded the number of account IDs in the master list
    if ( k <= length(account_ids))
    {
      account_id <- account_ids[k] #sets current account ID to the next one from the master list
    }
    else
    {
      loopBreak = TRUE #sets outer loopBreak to true
      break #breaks out of inner loop if there are no more entries in the master account ID list
    }

    ## Table 'account': takes accounts
    # Creating a path that can directly go into the API function with current account ID
    account_paths <- paste("/", "accounts", "/", account_id, sep = "")

    contents <- api_q(account_paths, "", oh_key)

    if(status_code(contents) == 200){
      info <- content(contents)

      account[k,1] <- account_ids[k]
      account[k,2] <- xml_node(info, 'id') %>% html_text() #unique ID for the account
      account[k,3] <- xml_node(info, 'name') %>% html_text()
      account[k,4] <- xml_node(info, 'created_at') %>% html_text() #account created at
      account[k,5] <- xml_node(info, 'updated_at') %>% html_text() #last updated at
      account[k,6] <- xml_node(info, 'about') %>% html_text() #account description
      account[k,7] <- xml_node(info, 'homepage_url') %>% html_text() #homepage URL
      account[k,8] <- xml_node(info, 'twitter_account') %>% html_text() #twitter handle
      account[k,9] <- xml_node(info, 'email_sha1') %>% html_text() #The SHA1 hex digest of the account email address

      account[k,10] <- xml_node(info, 'location') %>% html_text()
      account[k,11] <- xml_node(info, 'country_code') %>% html_text()
      account[k,12] <- xml_node(info, 'latitude') %>% html_text()
      account[k,13] <- xml_node(info, 'longitude') %>% html_text()

      account[k,14] <- xml_node(info, 'posts_count') %>% html_text()
      account[k,15] <- xml_node(info, 'kudo_score') %>% html_text()
      num_lang <- length(xml_nodes(info, 'experience_months') %>% html_text())
      account[k,16] <- (xml_nodes(info, 'name') %>% html_text())[2:(num_lang+1)] %>% paste(collapse = ";")
      account[k,17] <- xml_nodes(info, 'experience_months') %>% html_text() %>% paste(collapse = ";")
      account[k,18] <- xml_nodes(info, 'total_commits') %>% html_text() %>% paste(collapse = ";")
      account[k,19] <- xml_nodes(info, 'total_lines_changed') %>% html_text() %>% paste(collapse = ";")
      account[k,20] <- xml_nodes(info, 'comment_ratio') %>% html_text() %>% paste(collapse = ";")
    } else {
      account[k,1] <- account_ids[k]
    }
    print(k)

  }
  sub <- apply(account,1,function(x){all(is.na(x))})
  account1 <- account[!sub,]

  save(account1, file= paste0("./data/oss/original/openhub/users/user_tables/account_table_",Sys.Date(),"_",j,".RData")) #For most relevant accounts
}

write(k,"./data/oss/original/openhub/users/k_index.txt")

