# INPUT:
#        "~/oss/data/oss/working/pypi/05_prod_mature_names_w_osi_approved_status.csv"
# OUTPUT:
#        "~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv"
#        "~/oss/data/oss/working/pypi/07_names_prod_mature_osi_approved.csv"


library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)
api_key <- "1477f26c48cf30d2627d440f4544c548"

packages <- read.csv("~/oss/data/oss/working/pypi/05_prod_mature_names_w_osi_approved_status.csv")
packages$repository <- NA
osi_packages <- packages[grep(TRUE, packages$osi_approved), ]

for (i in 1:length(osi_packages$name))
{
  #i = 1
  Sys.sleep(1)
  api_url <- paste("https://libraries.io/api/pypi/", osi_packages$name[i], "?api_key=", api_key, sep="")
  api_response <- GET(api_url)

  if (status_code(api_response) == 200)
  {
    content <- content(api_response)
    hmpg <- as.character(content$homepage)
    repo <- as.character(content$repository_url)

    if ((length(hmpg) != 0) && (length(repo) != 0))
    {
      if (grepl("github", hmpg)) {
        osi_packages$repository[i] <- hmpg
      } else if (grepl("github", repo)) {
        osi_packages$repository[i] <- repo
      }
    }

    hmpg <- NULL
    repo <- NULL
    content <- NULL

    print(i)
  }

}

write.csv(osi_packages, "~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv")
write.csv(osi_packages$name, "~/oss/data/oss/working/pypi/07_names_prod_mature_osi_approved.csv")
