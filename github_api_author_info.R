#get an author's followers/follower numbers, emails, orgnization, location
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)
library(data.table)
###################################################################################
github_token = ''
token = str_c('token ',
              github_token)

general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
authors = str_extract(string = general_info$slugs, pattern = '(.*?)(?=/)')



#################################email and other general info
get_general = function(author) {
  if (!is.na(author)) {
    Sys.sleep(time = 8e-1)
    response = str_c('https://api.github.com/users/',
                     author) %>%
      GET(add_headers(Authorization = token))

    if(response$status_code == 200) {
      output = response %>%
        content(as = 'text', encoding = 'UTF-8') %>%
        fromJSON()

      result = data.table(author = output$login,
                          followers_number = output$followers,
                          following_number = output$following,
                          org = ifelse(is.null(output$company), NA, output$company),
                          loc = ifelse(is.null(output$location), NA, output$location),
                          email = ifelse(is.null(output$email), NA, output$email))

      return(result)
    }
  }
  return(data.table(author = author,
                    followers_number = 0,
                    following_number = 0,
                    org = NA,
                    loc = NA,
                    email = NA))
}
#################################affiliations; abandoned
response = str_c('https://api.github.com/users',
                 '/',
                 author,
                 '/',
                 'orgs') %>%
  GET(add_headers(Authorization = 'token 2d260070668afe675673e973faf2ec30b48e831c'))

output = response %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()

#################################followers
get_followers = function(author, number) {
  result = data.table()
  for (i in 1:ceiling(number/100)) {
    response = str_c('https://api.github.com/users',
                     '/',
                     author,
                     '/',
                     'followers?per_page=100&page=',
                     as.character(i)) %>%
      GET(add_headers(Authorization = token))
    if (i == 1 & response$status_code != 200) {
      break
    }
    output = response %>%
      content(as = 'text', encoding = 'UTF-8') %>%
      fromJSON()

    result = rbind(result, data.table(user = author, follower = output$login))
  }

  return(result)
}

###################################################################
author_general = list()
for(i in 1:length(authors)) {
  print(i)
  author_general[[i]] = get_general(authors[i])
}
author_general_unlisted = do.call(rbind, author_general)
