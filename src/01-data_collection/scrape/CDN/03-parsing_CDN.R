#parsing the one big data set into several subsets

#libraries and prep
library(dplyr)
library(stringr)
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)
rm(list = ls())

#read in raw response created by 01
before <- read.csv("data/oss/working/CDN/raw_response.csv", stringsAsFactors = FALSE, check.names=FALSE)


#general info
before <- read.csv("data/oss/working/CDN/raw_response.csv", stringsAsFactors = FALSE, check.names=FALSE)

#retain useful info only
general_info <- select(before, name, description, repository.type, repository.url)
outfile <- file.path("data/oss/final/CDN/general_info.csv")
write.csv(general_info, outfile, row.names = FALSE)





#functions
#parse keywords
#row is a row of the raw_response in df format/a package
#returns a df with each keyword as an entry
parse_kw = function(row) {
  name = row[1]
  if (is.na(x = row[2])) {
    output = data.frame(name = name, keyword = NA)
  } else {
    output = data.frame(name = name,
                        keyword = str_split(row[2], pattern = ", ") %>% unlist())
  }
  return(output)
}

#extract licences from raw response; least reliable license source
#row is a row of the raw_response in df format/a package
#returns a df with each license as an entry
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

#parce license
interm_lcnc = apply(before %>%
                      select(name, license, licenses),
                    MARGIN = 1,
                    FUN = parse_lcnc)

licence_info <- do.call(what = rbind, args = interm_lcnc)
row.names(licence_info) = NULL
#save
outfile <- file.path("data/oss/final/CDN/licence_info.csv")
write.csv(licence_info, outfile, row.names = FALSE)


#parse authors&author info
#row is the raw response in the form of df
#returns a df with author info
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




###################################
#script
#apply parse_kw
interm_kw = apply(X = before %>%
        select(name, keywords),
      MARGIN = 1,
      FUN = parse_kw)
keyword_info <- do.call(what = rbind, args = interm_kw)
row.names(keyword_info) = NULL

#save
outfile <- file.path("data/oss/final/CDN/keword_info.csv")
write.csv(keyword_info, outfile, row.names = FALSE)


#author info
parse_ausr(before[2,] %>%
             select(name, author, author.name, author.email, author.url))
interm_ausr = apply(before[1:5,] %>%
                      select(name, author, author.name, author.email, author.url),
                    MARGIN = 1,
                    FUN = parse_ausr)

author_info <- do.call(what = rbind, args = interm_ausr)
row.names(author_info) = NULL
#save
outfile <- file.path("data/oss/final/CDN/author_info.csv")
write.csv(author_info, outfile, row.names = FALSE)
