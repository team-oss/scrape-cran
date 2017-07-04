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

rm(list=ls())

#k <- write("k","~/git/oss/data/oss/original/openhub/projects/random/k_index.txt")

k <- read_file("./data/oss/original/openhub/projects/random/k_index.txt")

if(k == "k\n")
{
  k = 0
}else
{
  k = as.integer(str_split(k,"\n", n=1))
}


# pulls in vector of API keys
source("./src/sphadke/00_ohloh_keys.R")



#puts API keys into a named vector
curr_ls <- ls()
pattern <- '^oh_key_'
match <- grep(pattern = pattern, x = ls())
key_names <- curr_ls[match]
all_keys <- c()

source("./src/sphadke/00_ohloh_keys.R")
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
load("./data/oss/original/openhub/projects/random/project_ids/all_random_project_ids.RData")
project_ids <- all_random_project_ids

loopBreak = FALSE

project <- matrix(NA, length(project_ids), 33)
colnames(project) <- c("project_url_id", "project_name", "project_id", "created_at", "updated_at", "description", "homepage_url", "download_url", "url_name",
                       "user_count", "average_rating", "rating_count", "review_count",
                       "analysis_id", "analysis_url", "last_analysis_update", "last_source_code_access", "ohloh_first_month_of_analysis", "ohloh_latest_month_of_analysis",
                       "twelve_month_contributor_count", "total_contributor_count", "twelve_month_commit_count", "total_commit_count", "total_code_lines", "main_language",
                       "possible_urls", "ohloh_url", "factoids", "tags", "licenses",
                       "languages", "language_percentages", "activity_index")

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
  for(k in ((k+1):(k+1000)))
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


    contents <- api_q(project_paths, "", oh_key)

    if(status_code(contents) == 200){
      info <- content(contents)
      project[k,1] <- project_ids[k]
      project[k,2] <- xml_node(info, 'name') %>% html_text
      project[k,3] <- xml_node(info, 'id') %>% html_text() #unique ID for the project
      project[k,4] <- xml_node(info, 'created_at') %>% html_text() #project created at
      project[k,5] <- xml_node(info, 'updated_at') %>% html_text() #last updated at
      project[k,6] <- xml_node(info, 'description') %>% html_text() #Project description
      project[k,7] <- xml_node(info, 'homepage_url') %>% html_text() #homepage URL
      project[k,8] <- xml_node(info, 'download_url') %>% html_text() #download URL
      project[k,9] <- xml_node(info, 'url_name') %>% html_text() #URL name for ohloh URL
      project[k,10] <- xml_node(info, 'user_count') %>% html_text() #i use this
      project[k,11] <- xml_node(info, 'average_rating') %>% html_text()
      project[k,12] <- xml_node(info, 'rating_count') %>% html_text()
      project[k,13] <- xml_node(info, 'review_count') %>% html_text()
      project[k,14] <- xml_node(info, 'analysis_id') %>% html_text()
      project[k,15] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[2] #url for analysis in XML
      project[k,16] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[4] #last update for analysis
      project[k,17] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[5] #last time SCS was accessed for analysis
      project[k,18] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[6] #first month for which ohloh has monthly historical stats
      project[k,19] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[7] #last month for which ohloh has monthly historical stats; mostly current month
      project[k,20] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[8] #twelve month contributor count
      project[k,21] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[9] #total contributor count
      project[k,22] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[10] #twelve month commit count
      project[k,23] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[11] #total month commit count
      project[k,24] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[12] #total code lines
      project[k,25] <- (xml_contents(xml_node(info, 'analysis')) %>% html_text())[16] #main language
      project[k,26] <- xml_nodes(info, 'url') %>% html_text() %>% paste(collapse = ";")
      project[k,27] <- xml_node(info, 'html_url') %>% html_text()
      project[k,28] <- paste((xml_nodes(info, 'factoid') %>% xml_attr('type')), collapse = ";") #factoid
      project[k,29] <- xml_nodes(info, 'tag') %>% html_text() %>% paste(collapse = ';')
      project[k,30] <- paste(unlist((xml_node(info, 'licenses') %>% html_text() %>% str_split(pattern = 'gpl'))), collapse = ";")
      project[k,31] <- xml_children(xml_nodes(info, 'languages')) %>% html_text() %>% str_trim() %>% paste(collapse = ";")
      project[k,32] <- xml_children(xml_nodes(info, 'languages')) %>% xml_attr('percentage') %>% paste(collapse = ';')
      project[k,33] <- xml_node(info, 'project_activity_index') %>% html_text()

    } else {
      project[k,1] <- project_ids[k]
    }
    print(k)

  }
  sub<-apply(project,1,function(x){all(is.na(x))})
  project1<-project[!sub,]
  save(project1, file= paste0("./data/oss/original/openhub/projects/random/project_tables/project_table_",j ,"_",Sys.Date(),".RData"))
}

write(k,"./data/oss/original/openhub/projects/random/k_index.txt")

