#parsing the one big data set into several subsets
library(dplyr)
library(stringr)

rm(list = ls())

before <- read.csv("data/oss/working/CDN/raw_response.csv", stringsAsFactors = FALSE, check.names=FALSE)


#general info
before <- read.csv("data/oss/working/CDN/raw_response.csv", stringsAsFactors = FALSE, check.names=FALSE)

general_info <- select(before, name, description, repository.type, repository.url)
outfile <- file.path("data/oss/final/CDN/general_info.csv")
write.csv(general_info, outfile, row.names = FALSE)



# parse_kw = function(dest) {
#   for (i in 1:length(before$name)) {
#     if (is.na(before$keywords[i])) {
#
#     }
#     p_keywords = str_split(before$keywords[i], pattern = ", ") %>% unlist()
#     if (is.na(p_keywords)) {
#       dest <- rbind(dest,
#                     data.frame(name = before$name[i], keyword = NA))
#     } else {
#         new_rows = data.frame(name = before$name[i], keyword = p_keywords)
#         dest <- rbind(dest, new_rows)
#     }
#   }
#   return(dest)
# }



#keywords
parse_kw = function(row) {
  name = row[1]
  if (is.na(x = row[2])) {
    output = data.frame(name = name, keyword = NA)
  } else {
    output = data.frame(name = name,
                        keyword = str_split(row[2], pattern = ", ") %>% unlist())
  }
}
interm_kw = apply(X = before %>%
        select(name, keywords),
      MARGIN = 1,
      FUN = parse_kw)
keyword_info <- do.call(what = rbind, args = interm_kw)
row.names(keyword_info) = NULL

outfile <- file.path("data/oss/final/CDN/keword_info.csv")
write.csv(keyword_info, outfile, row.names = FALSE)



# process_license = function(dest, entry) {
#   if (is.na(entry$license) && is.na(entry$licenses)) {
#     dest <- rbind(dest,
#                   data.frame(name = entry$name, license = NA))
#   }
#   else {
#     if (!is.na(entry$license)) {
#       entry_license = entry$license
#       dest <- rbind(dest, data.frame(name = entry$name, license = entry_license))
#     }
#     if (!is.na(entry$licenses)) {
#       entry_licenses = str_split(entry$licenses, pattern = ",") %>% unlist()
#       for (i in 1:length(entry_licenses)) {
#         new_row = data.frame(name = entry$name, license = entry_licenses[i])
#         dest <- rbind(dest, new_row)
#       }
#     }
#   }
#   return(dest)
# }
#
# parse_license = function(dest) {
#   for (i in 1:nrow(before)) {
#     dest <- process_license(dest, before[i,])
#   }
#   return(dest)
# }

#licences; to differenciate from built-in R licence, all related fields are verb-spelled
parse_lcnc = function (row) {
  name = row[1]
  if (!is.na(row[2])) {
    output = data.frame(name = name, license = row[2])
  } else if (!is.na(row[3])) {
    output = data.frame(name = name, license = str_split(row[3], pattern = ", ") %>% unlist())
  } else {
    output = data.frame(name = name, license = NA)
  }
}

interm_lcnc = apply(before %>%
                      select(name, license, licenses),
                    MARGIN = 1,
                    FUN = parse_lcnc)

licence_info <- do.call(what = rbind, args = interm_lcnc)
row.names(licence_info) = NULL
outfile <- file.path("data/oss/final/CDN/licence_info.csv")
write.csv(licence_info, outfile, row.names = FALSE)
# length(unique(general_info$name))
# length(unique(licence_info2$name))
# nrow(licence_info2)
# setdiff(general_info$name, licence_info2$name)
# interm_lcnc[[2]]
# sapply(X = interm_lcnc, purrr::is_empty) %>% table()



#authors&author info
parse_ausr = function(row) {
  name = row[1]
  if (is.na(row[2]) && is.na(row[3])) {
    output = data.frame(name = name,
                        author.name = NA,
                        author.email = NA,
                        author.url = NA)
  } else if (!is.na(row[2])) {
    row = unlist(before[2,] %>%
                   select(name, author, author.name, author.email, author.url))
    output = data.frame(name = name,
                        author.name =
                          str_extract(string = row[2], pattern = '^.*?(?=[<|\\(])') %>%
                          str_trim(),
                        author.email = str_extract_all(row[2], '(?<=\\<).*?(?=\\>)'),
                        author.url = str_extract_all(name, '(?<=\\().*?(?=\\))'))
  } else {
    output = data.frame(name = name,
                        author.name = row[3],
                        author.email = row[4],
                        author.url = row[5])
  }
  return(value = output)
}

parse_ausr(before[2,] %>%
             select(name, author, author.name, author.email, author.url))
interm_ausr = apply(before[1:5,] %>%
                      select(name, author, author.name, author.email, author.url),
                    MARGIN = 1,
                    FUN = parse_ausr)

author_info <- do.call(what = rbind, args = interm_ausr)
row.names(author_info) = NULL
outfile <- file.path("data/oss/final/CDN/author_info.csv")
write.csv(author_info, outfile, row.names = FALSE)

# before <- read.csv("data/oss/original/CDN/raw_response.csv", stringsAsFactors = FALSE, check.names=FALSE)
# unite(before, author_info, c(author, authors, author.name, author.email, author.url, author.website, author.web, author.twitter), sep = ", ", remove=TRUE)
#
#
# dummy_data = data.frame(name = 1:2, authors = c('John Smith <j@s.com>, Cool Guy <awesome@cool.me>',
#                                                 'Jane Doe <jane@doe.edu'))
#
# parse_author = function(author_email) {
#   ...
# }
# parse_author = function(author_email) {
#   ...
# }
#
# magic = function(name, authors) {
#   authors =
#     data.frame(name = name, author = parse_authors, email =pars_)
# }
#
#
# 1-sapply(before, function(col) {sum(is.na(col))}) / nrow(before)
# str_extract(string = dummy_data$authors, pattern = '^.*?(?=[<|\\(])') %>% str_trim()
#
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)

response = str_c('https://api.github.com/',
                 'repos',
                 '/',
                 'lauripiispanen/angular-bacon',
                 '/',
                 'contents') %>%
  GET(add_headers(token = '2d260070668afe675673e973faf2ec30b48e831c'))
status_code(response)
kristoferjoseph/flexboxgrid

output = response %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON() %>%
  getElement(name = 'download_url')
output[str_detect(output, str_c('(', 'sanitize.css jn ', '|package).json$'))]



output = str_c('https://raw.githubusercontent.com/',
               'HubSpot',
               '/',
               'odometer',
               '/master/package.json') %>%
  GET() %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()

output$name
output$download_url
response$request
output2 = str_c('https://raw.githubusercontent.com/',
               'HubSpot',
               '/',
               'odometer',
               '/master/bower.json') %>%
  GET() %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()
keywords_info
author_info
license_info


dummy_data = data.frame(name = 1:2, authors = c('John Smith <j@s.com>, Cool Guy <awesome@cool.me>',
                                                'Jane Doe <jane@doe.edu'))

magic = function(name, authors) {
  authors =
    data.frame(name = name, author = parse_authors, email =pars_)
}
