##############for now do not use this one, assume all production ready



library(data.table)
library(stringr)
library(dplyr)
library(purrr)
library(httr)
library(jsonlite)

Github_API_token = "2d260070668afe675673e973faf2ec30b48e831c"

response = str_c('https://api.github.com/',
                 'repos',
                 '/',
                 str_extract(string = "https://github.com/bootflat/bootflat.github.io",
                             pattern = '(?<=github\\.com(/|:)).*') %>%
                   str_remove("(/|\\.git)$"),
                 '/',
                 'commits') %>%
  GET(add_headers(Authorization = 'token 2d260070668afe675673e973faf2ec30b48e831c'))
response = response %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()

commit_time = str_extract(response$commit$author$date[1], "(.*?)(?=T)")
