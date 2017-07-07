######################################################
#### Code for cleaning all orgs data from OpenHub ####
######################################################

#### Created by: sphadke
#### Creted on: 07/06/2017
#### Last edited on: 07/06/2017


####################
#### Cleanup
####################
rm(list=ls())
gc()
set.seed(312)


####################
#### Setup
####################
# library(plyr)
# library(stringr)

# Loading data: this should have been the original export
# Export from 01_ohloh_orgs_ids_and_table.R
organization <- read.csv("~/git/oss/data/oss/original/openhub/organizations/all_orgs_table.csv")


####################
#### Manually fixing name
#### and portfolio projects
#### On 06/27/2017
####################
organization <- read.csv("~/git/oss/data/oss/original/openhub/organizations/all_orgs_table.csv")

organization[21,5] <- 29
organization[27,5] <- 19
organization[34,5] <- 17
organization[39,5] <- 15
organization[44,2] <- "Facebook"
organization[44,5] <- 12
organization[49,5] <- 11
organization[78,5] <- 5
organization[86,5] <- 5
organization[92,5] <- 4
organization[110,5] <- 3
organization[124,5] <- 2
organization[127,5] <- 1
organization[133,2] <- "Samsung Electronics"
organization[133,5] <- 0
organization[148,2] <- "INRIA"
organization[148,5] <- 0
organization[159,5] <- 0
organization[167,5] <- 0
organization[167,2] <- "Liferay, Inc."
organization[280,2] <- "IBM Corporation"
organization[280,5] <- 0
organization[336,2] <- "Drupal"
organization[336,5] <- 0
organization[356,5] <- 0
organization[422,2] <- "Moodle Pty. Ltd."
organization[422,5] <- 0
organization[481,2] <- "phpBB Ltd."
organization[481,5] <- 0
organization[629,5] <- 0
organization[637,2] <- "LaBRI"
organization[637,5] <- 0
organization[638,5] <- 0
organization[640,5] <- 0
organization[646,2] <- "Microsoft Corporation"
organization[646,5] <- 0
organization[649,2] <- "Siemens AG"
organization[649,5] <- 0
organization[651,2] <- "CERN"
organization[651,5] <- 0
organization[678,2] <- "Igalia, S.L."
organization[678,5] <- 0
organization[687,2] <- "Oracle Corporation"
organization[687,5] <- 0
organization[690,2] <- "Kitware, Inc."
organization[690,5] <- 0
organization[697,2] <- "Arch Linux"
organization[697,5] <- 0
organization[698,2] <- "Google, Inc."
organization[698,5] <- 0

save(organization, file = "~/git/oss/data/oss/working/openhub/organizations/all_orgs_table.RData")


####################
#### Manually fixing name
#### and portfolio projects
#### On 06/27/2017
####################
load("~/git/oss/data/oss/working/openhub/organizations/all_orgs_table.RData")

## If 0 portfolio projects, columns 9, 10, 11 must be NA
for(i in 1:nrow(organization)){
  if(organization[i,6] == 0){
    organization[i,9] <- 0
    organization[i,10] <- 0
    organization[i,11] <- 0
  }
}


organization[698, 5] <- "Commercial"
organization[698, 6:17] <- c(0, NA, 42, )




