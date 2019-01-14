# obtaion info  with github api
# save author information, license, and version and dependencies as csv

#libraries and prep
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)
library(DBI)
library(sdalr)
source("functions_keren.R")
rm(list = ls())


#load data obtained from CDNJSAPI
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
# functions

#check if a repo is on github
#repo is a url
#returns true if the repo is not on github, true if otherwise
check_type = function (repo) {
  if (is.na(repo) | !str_detect(tolower(repo), "github.com")) {
    return(value = FALSE)
  } else {
    return(value = TRUE)
  }
}

#parse the link of a repo, so it fits the github api standard
parse_link = function (repo_link) {
  parsed_link = str_extract(string = repo_link,
                            pattern = '(?<=github\\.com(/|:)).*') %>%
    str_remove("(/|\\.git)$")
  return(value = parsed_link)
}

#use the api to obtain the info of a package
#row is a row in a df, which has its 1st column as package name,
#and 2nd column as repo url
#this function saves a json file for that package, if the repo is found on github,
#and returns a 1*2 df, with 1st column as package name, 2nd column as status
#status is a boolean; if a json file is downloaded, the status is true; false if otherwise
request_output = function (row) {
  Sys.sleep(runif(1) * 1)

  found = FALSE
  pkg = row[1]
  
  #if the repo is on github
  if (check_type(row[2])) {
    repo_link = row[2]
    parsed_link = parse_link(repo_link)

    #do request
    response = str_c('https://api.github.com/',
                     'repos',
                     '/',
                     parsed_link,
                     '/',
                     'contents') %>%
      GET(add_headers(Authorization = 'token 2d260070668afe675673e973faf2ec30b48e831c'))

    #status 200 means the repo is found
    if (status_code(response) == 200) {
      #extract package download urls, which potentially contains package info file
      output = response %>%
        content(as = 'text', encoding = 'UTF-8') %>%
        fromJSON() %>%
        getElement(name = 'download_url')
      #extract all json files provided
      candidates = output[str_detect(output, ".json$")] %>% na.omit

      #locate the best-match package info file
      if (!is_empty(candidates)) {
        candidate = candidates[str_detect(candidates, "package")]
        if (is_empty(candidate)) {
          candidate = candidates[str_detect(candidates, "bower")]
        }
        if (is_empty(candidate)) {
          candidate = candidates[str_detect(candidates, row[1])]
        }
        if (is_empty(candidate)) {
          candidate = candidates[1]
        }
      }

      #try to download the desired json info file
      try({
        download.file(url = candidate[1],
                      destfile = str_c("./data/oss/original/CDN/CDN_json/", pkg, ".json"))
        found = TRUE
        }
          ,silent = TRUE)


    }
    # if the json file is not found, look into potential directories
    else {
      candidates = c("/master/package.json",
                     "/gh-pages/package.json",
                     "/master/bower.json",
                     "/gh-pages/bower.json")

      for (candidate in candidates) {
        xxx = str_c("https://raw.githubusercontent.com/",
                    parsed_link,
                    candidate) %>%
          GET()

        #if found, the status code should be 200, save the json file
        if (status_code(xxx) == 200L) {
          xxx %>%
            content(as = 'text') %>%
            writeLines(con = './data/oss/original/CDN/CDN_json/', pkg, ".json")
          found = TRUE
          break()
         }
      }
    }
  }
  #return request status
  return(value = data.frame(name = pkg,
                            status = found))
}

#############################################################################################
# script

#parse and save the version and dependencies info,ignore dependency versions

#do the request
request_status = apply(X = general_info %>%
                         select(name, repository.url),
                       MARGIN = 1,
                       FUN = request_output)

#collapse and trim row names
result_status = do.call(what = rbind, args = request_status)
rownames(x = result_status) = NULL
#save status as csv
outfile <- file.path("data/oss/final/CDN/request_status.csv")
write.csv(result_status, outfile, row.names = FALSE)

#pull out and store useful data with functions defined previously
#empty dfs
authors = data.frame()
licenses = data.frame()
dependencies = data.frame()

#extract json file names
filenames = str_c('./data/oss/original/CDN/CDN_json',
                  list.files(path = './data/oss/original/CDN/CDN_json'),
                  sep = '/')
filename = './data/oss/original/CDN/CDN_json/TremulaJS.json'

#for each json file, extract authors, licenses, and dependencies
for(filename in filenames) {
  print(filename)
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN/CDN_json/).*') %>%
    str_remove(".json$")
  
  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()
  
  author = parse_author_info(pkg_name, json_file)
  license = parse_license_info(pkg_name, json_file)
  denpendency = parse_denpendency_info(pkg_name, json_file)
  
  authors = rbind(authors, author)
  licenses = rbind(licenses, license)
  dependencies = rbind(dependencies, denpendency)
}

#upload author, license, and dependency info
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CDN_authors_info",
             value = authors,
             row.names = FALSE,
             overwrite = TRUE)
dbWriteTable(con = my_db_con,
             name = "CDN_licenses_info",
             value = licenses,
             row.names = FALSE,
             overwrite = TRUE)
dbWriteTable(con = my_db_con,
             name = "CDN_dependencies_info",
             value = dependencies,
             row.names = FALSE,
             overwrite = TRUE)
dbWriteTable(con = my_db_con,
             name = "cdn_keywords_info",
             value = keword_info,
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))
