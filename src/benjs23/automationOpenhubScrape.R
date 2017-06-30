### Created by: benjs23
### Date: 6/29/2017

####### This code automates the scraping from OpenHub. It loads a list of API keys
####### and takes a function name as input. It automatically runs through every API
####### key, pulls the user specified tables, and tracks what information has been
####### collected.

library(httr)
library(plyr)
library(rvest)
library(stringr)
library(XML)
library(rio)
library(readr)




k <- read_file("~/git/oss/data/oss/original/openhub/projects/random/k_index.txt")

if(k == "k\n")
{
  k = 0
}else
{
  k = as.integer(str_split(k,"\n", n=1))
}


# pulls in vector of API keys
source("~/git/oss/src/sphadke/00_ohloh_keys.R")



#puts API keys into a named vector
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


# Function to create the correct path and get xml format data from it
api_q <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                      path, #page URL
                      page_no, #must be in form "page=n"
                      api_key))
  return(info)
}

# Get project IDs
load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/all_random_project_ids.RData")
project_ids <- all_random_project_ids

loopBreak = FALSE

#outer loop runs through the list of every API key
for(j in 1:length(all_keys))
{
  #break out of loop if all of the keys have been used
  if(loopBreak == TRUE)
  {

    break
  }

  #sets current API key
  oh_key <- paste(all_keys[j])
  #creates inner loop index variable to be equal to the first number in the next set of 1000 project IDs
  k = (length(project_ids) - (length(project_ids)-k))

  #loops through the next 1000 project IDs (this is how many calls you're allowed per API key per day)
  for(k in (k+1):k+1000)
{

  ################################
  #### Pulling the table from ohloh
  ################################

  #checks that index k has not exceeded the number of project IDs in the master list
  if ( k <= length(project_ids))
  {
  project_id <- project_ids[k] #sets current project ID to the next one from the master list
  }
  else
  {
    loopBreak = TRUE #sets outer loopBreak to true
    break #breaks out of inner loop if there are no more entries in the master project ID list
  }

  ## Table 'project': takes projects
  # Creating a path that can directly go into the API function with current project ID
  project_paths <- paste("/", "projects", "/", project_id, sep = "")


  project <- matrix(NA, length(project_ids), 5)
  colnames(project) <- c("project_url_id", "project_name", "user_count", "average_rating", "tags")


    contents <- api_q(project_paths, "", oh_key)

    if(status_code(contents) == 200){
      info <- content(contents)

      project[k,1] <- project_ids[k]
      project[k,2] <- xml_node(info, 'name') %>% html_text
      project[k,3] <- xml_nodes(info, 'user_count') %>% html_text()
      project[k,4] <- xml_nodes(info, 'average_rating') %>% html_text()
      project[k,5] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
    } else {
      project[i,1] <- project_ids[i]
    }
    print(k)

  }
  write(project, paste0("~/git/oss/data/oss/original/openhub/projects/project_info_tables/project_table_",j ,"_",Sys.Date()))
}

write(k,"~/git/oss/data/oss/original/openhub/projects/random/k_index.txt")

