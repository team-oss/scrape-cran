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

organization$org_name <- as.character(organization$org_name)

## If 0 portfolio projects, columns 9, 10, 11 must be NA
for(i in 1:nrow(organization)){
  if(organization[i,6] == 0){
    organization[i,9] <- 0
    organization[i,10] <- 0
    organization[i,11] <- 0
    organization[i, 12 ] <- 0
    organization[i, 13 ] <- 0
    organization[i, 14 ] <- 0
  }
}






organization[698, 5] <- "Commercial"
organization[698, 8:17] <- c(42, 0, 0, 0, 0, 0, 0, 594,302759, 42)


organization[697, 5] <- "Non-Profit"
organization[697, 8:17] <- c(6, 0, 0, 0, 0, 0, 0, 52, 38099, 6)


organization[690, 5] <- "Commercial"
organization[690, 8:17] <- c(11, 0, 0, 0, 0, 0, 0, 68, 83048, 11)

organization[687, 5] <- "Commercial"
organization[687, 8:17] <- c(13, 0, 0, 0, 0, 0, 0, 89, 37270, 13)

organization[678, 5] <- "Commercial"
organization[678, 8:17] <- c(22, 0, 0, 0, 0, 0, 0, 292, 413119, 22)

organization[651, 5] <- "Government"
organization[651, 8:17] <- c(14, 0, 0, 0, 0, 0, 0, 40, 78890, 14)

organization[649, 5] <- "Commercial"
organization[649, 8:17] <- c(7, 0, 0, 0, 0, 0, 0, 72, 50333, 7)

organization[646, 5] <- "Commercial"
organization[646, 8:17] <- c(12, 0, 0, 0, 0, 0, 0, 138, 106412, 12)

organization[640, 3] <- "INTEL Corporation"
organization[640, 5] <- "Commercial"
organization[640, 8:17] <- c(48, 0, 0, 0, 0, 0, 0, 364, 380210, 48)

organization[638, 3] <- "Red Hat, Inc."
organization[638, 5] <- "Commercial"
organization[638, 8:17] <- c(218, 0, 0, 0, 0, 0, 0, 2474, 1668391, 218)

organization[637, 5] <- "Education"
organization[637, 8:17] <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

organization[629, 3] <- "SUSE"
organization[629, 5] <- "Commercial"
organization[629, 8:17] <- c(23, 0, 0, 0, 0, 0, 0, 431, 223132, 23)

organization[481, 5] <- "Non-Profit"
organization[481, 8:17] <- c(4, 0, 0, 0, 0, 0, 0, 11, 10740, 4)

organization[422, 5] <- "Commercial"
organization[422, 8:17] <- c(6, 0, 0, 0, 0, 0, 0, 22, 30481, 6)

organization[356, 3] <- "Fedora Project"
organization[356, 5] <- "Non-Profit"
organization[356, 8:17] <- c(22, 0, 0, 0, 0, 0, 0, 177, 87638, 22)

organization[336, 3] <- "Drupal"
organization[336, 5] <- "Non-Profit"
organization[336, 8:17] <- c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

organization[280, 5] <- "Commercial"
organization[280, 8:17] <- c(22, 0, 0, 0, 0, 0, 0, 151, 110026, 22)

organization[167, 5] <- "Commercial"
organization[167, 8:17] <- c(1, 0, 0, 0, 0, 0, 0, 1, 6100, 1)

organization[159, 3] <- "Huawei"
organization[159, 5] <- "Commercial"
organization[159, 8:17] <- c(1, 0, 0, 0, 0, 0, 0, 12, 1064, 12)

organization[148, 5] <- "Government"
organization[148, 8:17] <- c(11, 0, 0, 0, 0, 0, 0, 129, 91942, 11)

organization[133, 5] <- "Commercial"
organization[133, 8:17] <- c(35, 0, 0, 0, 0, 0, 0, 172, 188510, 35)

organization[127, 3] <- "Collabora, Ltd."
organization[127, 5] <- "Commercial"
organization[127, 8:17] <- c(34, 12, 615588, 1, 67, 3437033, 1, 699, 200278, 34)

organization[124, 3] <- "Cisco Systems, Inc."
organization[124, 5] <- "Commercial"
organization[124, 8:17] <- c(12, 0, 0, 0, 7, 1186, 2, 127, 233141, 12)

organization[110, 3] <- "Savoir-faire Linux"
organization[110, 5] <- "Commercial"
organization[110, 8:17] <- c(12, 6, 1522, 2, 19, 8788, 2, 135, 8027, 12)

organization[92, 3] <- "Nuxeo"
organization[92, 5] <- "Commercial"
organization[92, 8:17] <- c(6, 6, 34536, 2, 39, 46724, 2, 53, 1784, 5)

organization[86, 3] <- "Codethink Ltd."
organization[86, 5] <- "Commercial"
organization[86, 8:17] <- c(30, 22, 8232, 5, 6, 1120, 2, 573, 156541, 28)

organization[78, 3] <- "Google"
organization[78, 5] <- "Commercial"
organization[78, 8:17] <- c(19, 6, 10876, 3, 237, 123387, 4, 562, 371852, 19)

organization[49, 3] <- "Wind River"
organization[49, 5] <- "Commercial"
organization[49, 8:17] <- c(19, 9, 1155, 9, 9, 42, 3, 176, 34481, 18)

organization[44, 5] <- "Commercial"
organization[44, 8:17] <- c(15, 4, 442, 3, 33, 5515, 7, 290, 82268, 15)

organization[39, 3] <- "Gentoo Foundation"
organization[39, 5] <- "Non-Profit"
organization[39, 8:17] <- c(19, 18, 40959, 12, 119, 109395, 13, 767, 251618, 17)

organization[34, 3] <- "Catalyst IT"
organization[34, 5] <- "Commercial"
organization[34, 8:17] <- c(20, 7, 1609, 8, 52, 16430, 11, 170, 29805, 20)

organization[27, 3] <- "Adobe"
organization[27, 5] <- "Commercial"
organization[27, 8:17] <- c(26, 9, 128181, 10, 25, 97837, 11, 164, 72193, 25)

organization[21, 3] <- "Debian"
organization[21, 5] <- "Non-Profit"
organization[21, 8:17] <- c(43, 38, 116759, 19, 528, 714145, 29, 1085, 223844, 43)

save(organization, file = "~/git/oss/data/oss/final/openhub/organizations/all_orgs_table_final.RData")


