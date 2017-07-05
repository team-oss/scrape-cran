###################################################
#### OpenHub API: random sample of project IDs ####
###################################################
# Don't edit without checking-in with Sayali

#### Created by: sphadke
#### Authors: sphadke, benjs23
#### Creted on: 06/29/2017
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

## API keys
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

# total_pages <- 67648
# total_random_sample <- 80000
# total_random_pages <- total_random_sample/10
# pages_to_pull <- sample(x = 1:total_pages, size = total_random_pages,
#                         replace = FALSE, prob = rep(1/total_pages, total_pages))
# pages_to_pull <- sort(pages_to_pull)
# save(pages_to_pull, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/sample_pages_to_pull.RData")

# We pull IDs for projects on the 8000 randomly chosen pages
# They go into a path, which then feeds into the API call to then pull table

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/sample_pages_to_pull.RData")

## Projects
# random_project_ids <- vector()

pulling_random_project_ids <- function(j, k, key){
  random_project_ids <- c()
  #j: start page index
  #k: end page index
  for (i in j:k){
    page <- pages_to_pull[i]
    get_projects <- api_q("/projects", paste("page=", page, sep = ""), key)
    projects <- content(get_projects, as = "parsed")
    ids <- str_split((xml_nodes(projects, 'html_url') %>% html_text()), "/", simplify = TRUE)[,5]
    random_project_ids <- c(random_project_ids, ids)
    print(i)
  }
  return(random_project_ids)
}

# random_project_ids <- pulling_random_project_ids(1, 5, oh_key_sp)
#
# random_project_ids <- unique(random_project_ids)
# save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_*.RData")
load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_8.RData")
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

random_project_ids <- pulling_random_project_ids(1, 800, oh_key_ssp)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_1.RData")


####
#### Part 2
####

random_project_ids <- pulling_random_project_ids(801, 1600, oh_key_sep)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_2.RData")


####
#### Part 3
####

random_project_ids <- pulling_random_project_ids(1601, 2400, oh_key_km)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_3.RData")


####
#### Part 4
####

random_project_ids <- pulling_random_project_ids(2401, 3200, oh_key_dc)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_4.RData")


####
#### Part 5
####

random_project_ids <- pulling_random_project_ids(3201, 4000, oh_key_ei)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_5.RData")


####
#### Part 6
####

random_project_ids <- pulling_random_project_ids(4001, 4800, oh_key_rf)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_6.RData")


####
#### Part 7
####

random_project_ids <- pulling_random_project_ids(4801, 5600, oh_key_cl)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_7.RData")


####
#### Part 8
####

random_project_ids <- pulling_random_project_ids(5601, 6400, oh_key_ck)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_8.RData")


####
#### Part 9
####

random_project_ids <- pulling_random_project_ids(6401, 7200, oh_key_cm)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_9.RData")


####
#### Part 10
####

random_project_ids <- pulling_random_project_ids(7201, 8000, oh_key_hs)
random_project_ids <- unique(random_project_ids)
save(random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_10.RData")


####
#### To put them all together
####

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_1.RData")
one <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_2.RData")
two <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_3.RData")
three <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_4.RData")
four <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_5.RData")
five <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_6.RData")
six <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_7.RData")
seven <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_8.RData")
eight <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_9.RData")
nine <- random_project_ids

load("~/git/oss/data/oss/original/openhub/projects/random/project_ids/random_project_ids_10.RData")
ten <- random_project_ids

all_random_project_ids <- c(one, two, three, four, five, six, seven, eight, nine, ten)
save(all_random_project_ids, file = "~/git/oss/data/oss/original/openhub/projects/random/project_ids/all_random_project_ids.RData")


