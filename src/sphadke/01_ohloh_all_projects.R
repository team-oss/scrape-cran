#####################
#### OpenHub API ####
#### project IDs ####
#####################
# Don't edit without checking-in with Sayali

#### Created by: sphadke
#### Authors: sphadke, benjs23
#### Creted on: 06/27/2017
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

##
## API keys
##
source("~/git/oss/src/sphadke/00_ohloh_keys.R")
avail_keys <- length(grep("oh_key", ls()))
avail_keys
api_keys <- grep("oh_key", ls(), value = TRUE)



# Function to create the correct path, get xml from it
api_q <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                path, #page URL
                page_no, #must be in form "page=n"
                api_key))
  return(info)
}


####################
#### Pulling ids
####################
# We create IDs for as many projects as possible
# They go into a path, which then feeds into the API call to then pull table

## Projects
# project_ids <- vector()
# j <-  #number of the first page being pulled on this call
# k <-  #number of the last page being pulled on this call
# for (i in j:k){
#   get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_)
#   projects <- content(get_projects, as = "parsed")
#   ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
#   ids
#   project_ids <- c(project_ids, ids)
#   print(i)
# }
#
# project_ids <- unique(project_ids)
# save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_5.R")
# load("~/git/oss/data/oss/original/openhub/projects/all_project_ids_.R")
# head(project_ids)


####################
## Lazy code Sayali wrote to run org_ids pull in the background.
## Actual implementation was done using separate codefiles,
## since there was no guarantee of finishing it before midnight,
## which is when the keys (hopefully) replenish.
## Those separate files have been deleted.
####################

####
#### Part 1
####

project_ids <- vector()
k <- 1#number of pages possible on the given API key
for (i in 999:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_gk)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_1.R")


####
#### Part 2
####

project_ids <- vector()
k <- 1994#number of pages possible on the given API key
for (i in 1000:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_cl)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_2.R")


####
#### Part 3
####

project_ids <- vector()
k <- 2993#number of pages possible on the given API key
for (i in 1995:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_cm)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_3.R")


####
#### Part 4
####

project_ids <- vector()
k <- 2994#number of pages possible on the given API key
for (i in 3400:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_ei)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_4.R")


####
#### Part 5
####

project_ids <- vector()
k <- 4400#number of pages possible on the given API key
for (i in 3401:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_sep)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_5.R")


####
#### Part 6
####

project_ids <- vector()
k <- 5395#number of pages possible on the given API key
for (i in 4401:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_sp)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_6.R")


####
#### Part 7
####

project_ids <- vector()
k <- 6390#number of pages possible on the given API key
for (i in 5396:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_ssp)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_7.R")


####
#### Part 8
####

project_ids <- vector()


k <- 7385#number of pages possible on the given API key
for (i in 6391:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_old)

  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)


save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_8.R")

####
#### Part 9
####

project_ids <- vector()
k <- 8380#number of pages possible on the given API key
for (i in 7386:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_bjs)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_9.R")


####
#### Part 10
####

project_ids <- vector()
k <- 9375#number of pages possible on the given API key
for (i in 8381:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_lk)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_10.R")


####
#### Part 11
####

project_ids <- vector()
k <- 10370#number of pages possible on the given API key
for (i in 9376:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_km)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_11.R")


####
#### Part 12
####

project_ids <- vector()
k <- 11365#number of pages possible on the given API key
for (i in 10371:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_ck)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_12.R")


####
#### Part 13
####

project_ids <- vector()
k <- 12360#number of pages possible on the given API key
for (i in 11366:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_kl)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_13.R")


####
#### Part 14
####

project_ids <- vector()
k <- 13355#number of pages possible on the given API key
for (i in 12361:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_lc)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_14.R")


####
#### Part 15
####

project_ids <- vector()
k <- 14350#number of pages possible on the given API key
for (i in 13356:k){
  get_projects <- api_q("/projects", paste("page=", i, sep = ""), oh_key_hs)
  projects <- content(get_projects, as = "parsed")
  ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
  ids
  project_ids <- c(project_ids, ids)
  print(i)
}

project_ids <- unique(project_ids)
save(project_ids, file = "~/git/oss/data/oss/original/openhub/projects/all_project_ids_15.R")



