#get star and watch counts for a repo
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)
library(data.table)
#################################################
github_token = ''
token = str_c('token ',
              github_token)

general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)

slugs = general_info$slugs

################################################
get_popularity = function(slug) {
  response = str_c('https://api.github.com/repos/',
                   slug) %>%
    GET(add_headers(Authorization = token))

  if(response$status_code == 200) {
    output = response %>%
      content(as = 'text', encoding = 'UTF-8') %>%
      fromJSON()

    result = data.table(slug = slug,
                        star_count = output$stargazers_count,
                        watch_count = output$watchers_count)
  }

  return(result)
}
#####################################
popularity_list = list()
for(i in 1:length(slugs)) {
  print(i)
  popularity_list[[i]] = get_popularity(slugs[[i]])
}
