#scarping cdnjs with CDN API
# this phase obtains project names, repo url, and least realiable package info

#libraries and prepare
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)

rm(list = ls())

#function
#extract keywords, licenses, and authors as a dataframe
#arg is a vector containing CDNJS package info returned by CDNJS API
extract_info = function(arg) {
  if ('keywords' %in% names(arg)) {
    arg$keywords = str_c(arg$keywords, collapse = ', ')
  }
  if ('licenses' %in% names(arg)) {
    arg$licenses = str_c(arg$licenses, collapse = ', ')
  }
  if ('authors' %in% names(arg)) {
    arg$authors = str_c(arg$authors, collapse = ', ')
  }
  if (length(arg$keywords) == 0) {
    arg$keywords <- c(NA)
  }
  #construct dataframe
  output = as.data.frame(arg[names(arg) %in% columns],
                         stringsAsFactors = FALSE)
  return(output)
}




####code

#get all package names with CDN API
response = GET(url = 'https://api.cdnjs.com/libraries/') %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()

name = response$results$name

#empty vector
info <- vector(mode = "list", length = length(name))

#request info for each package
for (i in 1:length(name)) {
  print(i)
  #request each pachages info with CDN API
  info[[i]] <- GET(url = str_c("https://api.cdnjs.com/libraries/", name[i])) %>%
    content(as = 'text', encoding = 'UTF-8') %>%
    fromJSON()
  
  Sys.sleep(runif(1) * 0.2)
}

#name columns of result df properly
columns = c("name", "description", "homepage", "keywords",
            "repository", "license", "licenses", "author", "authors")

#apply function to extract package info
output = map_df(.x = info,
                .f = extract_info)


#save RDS
saveRDS(info, file = 'data/oss/working/CDN/raw_response.RDS')
outfile <- file.path("data/oss/working/CDN/raw_response.csv")
write.csv(output, outfile, row.names = FALSE)
