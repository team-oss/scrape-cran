# INPUT:
#        "~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv"
# OUTPUT:
#        "~/oss/data/oss/working/pypi/10_github_and_additional_info.csv"

library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)

osi_production_mature <- read.csv("~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv")
osi_production_mature$latest_release_date <- NA
osi_production_mature$version <- NA

num_pkg <- nrow(osi_production_mature)

for (i in 7303:num_pkg)
{
  #Sys.sleep(2)
  url <- paste("https://pypi.org/project/", osi_production_mature$name[i], sep = "")
  html <- read_html(url)
  nm <- html %>% html_nodes('.package-header__name') %>% html_text()
  nm <- strsplit(nm, "\n")[[1]][2]
  osi_production_mature$version[i] <- strsplit(nm, " ")[[1]][10]

  osi_production_mature$latest_release_date[i] <- (html %>% html_nodes('.-js-relative-time') %>% html_text())[1]
  print(i)
}

write.csv(osi_production_mature, "~/oss/data/oss/working/pypi/10_github_and_additional_info.csv")
