library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)
api_key <- "1477f26c48cf30d2627d440f4544c548"
prod_mature_packages <- read.csv("~/oss/data/oss/final/PyPI/all_production_mature.csv")
# prod_mature_packages$license <- NA
#
# names_list <- prod_mature_packages$name

for (i in 6390:length(names_list))
{
  Sys.sleep(1)
  api_url <- paste("https://libraries.io/api/pypi/", names_list[i], "?api_key=", api_key, sep="")
  api_response <- GET(api_url)

  if (status_code(api_response) == 200)
  {
    content <- content(api_response)
    license <- as.character(content$normalized_licenses)

    if (length(license) != 0)
    {
      prod_mature_packages$license[i] <- license
    }

    content <- NULL
    license <- NULL
    print(i)
  }
}
#write.csv(names_list, "~/oss/data/oss/final/PyPI/production_mature_licenses1.csv")
write.csv(prod_mature_packages, "~/oss/data/oss/final/PyPI/production_mature_licenses.csv")






