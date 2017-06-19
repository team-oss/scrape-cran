########################################################################
##### Code to pull info from OpenHub API: assumes known inputs for #####
#### account_id, project_id, org_name, analysis_id, or org_url_name ####
########################################################################

#### Created by: sphadke, benjs23
#### Creted on: 06/15/2017
#### Last edited on: 06/18/2017


####
#### Cleanup
####
rm(list=ls())
gc()
set.seed(312)


####
#### Setup
####
library(httr)
library(rvest)
library(XML)


####
#### Test: pulling information in the Account section
####

# Function to pull from openhub
# All thanks to Daniel Chen, and help from https://github.com/r-lib/httr/blob/master/vignettes/api-packages.Rmd and http://bradleyboehmke.github.io/2016/01/scraping-via-apis.html#httr_api

#
oh_key <- "d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1"

proj_path <- '/projects/firefox'
user_path <- '/accounts/odvarko'
org_path <- '/orgs/mozilla'
api_q <- sprintf('https://www.openhub.net%s.xml?api_key=%s',
                 path,
                 oh_key)

r <- content(GET(api_q), as = "parsed")


openhub_api <- function(path) {
  url <- modify_url("https://www.openhub.net", path = path,
                    query = list(api_key = oh_key))
  #GET(url, content_type_xml())
}

s <- 'https://www.openhub.net/projects/firefox.xml?api_key=d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1'

api_q <- sprintf('https://www.openhub.net%s.xml?api_key=%s',
                 '/projects/firefox',
                 oh_key
                 )

GET(s)

# Single project
proj_one <- openhub_api("/projects/firefox")
proj_one
proj_one_info <- content(proj_one, as = "parsed")
content(proj_one, "text")
content(proj_one, as = "parsed")

all_projs <- openhub_api("/projects")


# Single user
user_one <- openhub_api("/accounts/odvarko")
cont <- content(user_one)

rvest::html_nodes(cont, '.pull-left')

library(rvest)

user_two <- openhub_api("/accounts/Stefan")
all_accounts <- openhub_api("/accounts")


# Single organization
org_one <- openhub_api("/orgs/mozilla")

