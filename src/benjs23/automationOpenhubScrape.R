### Created by: benjs23
### Date: 6/29/2017

####### This code automates the scraping from OpenHub. It loads a list of API keys
####### and takes a function name as input. It automatically runs through every API
####### key, pulls the user specified tables, and tracks what information has been 
####### collected.



source("~/git/oss/src/sphadke/00_ohloh_keys.R")

k = 0

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


# Function to create the correct path, get xml from it
api_q <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                      path, #page URL
                      page_no, #must be in form "page=n"
                      api_key))
  return(info)
}

# Get project IDs
load("~/git/oss/data/oss/original/openhub/projects/all_project_ids_1.R") ##merge all project IDS to single file

loopBreak = FALSE
for(j in 1:length(all_keys))
{

  if(loopBreak == TRUE)
  {
    break
  }
  
  oh_key <- paste(all_keys[j]) #updates API key
  
  k = (length(project_ids) - (length(project_ids)-k))  #create k index 
  
  for(k in (k+1):k+1000)
{
  ####################
  #### Pulling the table
  ####################
  
  # Choose which IDs, or how many of the IDs to use for the session
  if ( k <= length(project_ids))
  {
  project_id <- project_ids[k]
  }
  else
  {
    loopBreak = TRUE
    break
  }
  ## Table 'project': takes projects
  # Creating a path that can directly go into the API function
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
  write(project, paste0("~/git/oss/data/oss/original/openhub/projects/project_table_",j ,Sys.Date()))
}

