# construct and save author information, license, and version and dependencies as csv with github api
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)
library(DBI)
library(sdalr)

rm(list = ls())



general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)

#parse each componet of authors
# parse_each_author = function(pkg, input) {
#   author_names = str_extract(string = input, pattern = '^.*?(?=[<|\\(])') %>% str_trim()
#   if (author_names == "") {
#     author_names = NA
#   }
#   author_emails = str_extract_all(string = input, '(?<=\\<).*?(?=\\>)')
#   if (author_emails == "") {
#     author_emails = NA
#   }
#
#   result = data.frame(name = pkg,
#                       author.name = author_names,
#                       author.email = author_emails)
#
#   return(result)
# }

parse_author_email = function(x) {
  result = data.frame()
  if (is(x, "character")) {
    author_names = str_extract(string = x,
                               pattern = '^.*?(?=\\s\\<|\\(|$)')
    author_emails = str_extract(string = x,
                                pattern = '(?<=\\<).*?(?=\\>)')
    result = data.frame(author = author_names,
                        email = author_emails)
  } else if (is(x, "list")) {
    result = data.frame(author = x[[1]],
                        email = ifelse(length(x) >= 2, x[[2]], NA))
  } else if (is(x, "data.frame")) {
    result = x[, 1:2]
    colnames(result) <-  c("author", "email")
  }
  return(value = result)
}

#parse and save the author's/authors' name and email
parse_author_info = function (pkg_name, json_file) {
  if (is.null(json_file$author) && is.null(json_file$authors)) {
    result = data.frame(name = pkg_name,
                        author = NA,
                        email = NA)
  } else {
    if (!is.null(json_file$author)) {
      feed = json_file$author
    } else if (!is.null(json_file$authors)) {
      feed = json_file$authors
    }

    result = parse_author_email(feed) %>%
      mutate(name = pkg_name)
  }

  return(value = result)
}

#parse and save the license info
parse_license_info = function (pkg_name, json_file) {
  if(!is.null(json_file$licenses)) {
    if (is(json_file$licenses, "data.frame")) {
      #print(json_file$licenses)
      license = json_file$licenses[[1]]
    } else if (is(json_file$licenses, "list")) {
      license = json_file$licenses$type
    } else {
      license = json_file$licenses
    }
    # result = data.frame(license = license) %>%
    #   mutate(name = output$name)
  } else if (!is.null(json_file$license)) {
    if (is(json_file$license, "data.frame")) {
      license = json_file$license[[1]]
    } else if (is(json_file$license, "list")) {
      license = json_file$license$type
    } else {
      license = json_file$license
    }
  } else {
    license = NA
    # result = data.frame(name = output$name,
    #                     license = NA)
  }

  result = data.frame(license = license) %>%
    mutate(name = pkg_name)

  return(value = result)
}


#parse and save the version and dependency info

#######(MIT)
parse_denpendency_info = function (pkg_name, json_file) {
  version = json_file$version
  dependency = json_file$devDependencies %>% names

  if (is.null(json_file$version)) {
    version = NA
  }

  if (is.null(json_file$devDependencies)) {
    dependency = NA
  }

  result = data.frame(dependency = json_file$devDependencies %>% names) %>%
    mutate(name = pkg_name) %>%
    mutate(version = version)

  return(value = result)
}

#check if the repo type is github
check_type = function (repo) {
  if (is.na(repo) | !str_detect(tolower(repo), "github.com")) {
    return(value = FALSE)
  } else {
    return(value = TRUE)
  }
}

#parse the link to a repo
parse_link = function (repo_link) {
  parsed_link = str_extract(string = repo_link,
                            pattern = '(?<=github\\.com(/|:)).*') %>%
    str_remove("(/|\\.git)$")
  return(value = parsed_link)
}

#use the api to obtain the info of a package
request_output = function (row) {
  Sys.sleep(runif(1) * 1)

  found = FALSE
  pkg = row[1]

  if (check_type(row[2])) {
    repo_link = row[2]
    parsed_link = parse_link(repo_link)

    response = str_c('https://api.github.com/',
                     'repos',
                     '/',
                     parsed_link,
                     '/',
                     'contents') %>%
      GET(add_headers(Authorization = 'token 2d260070668afe675673e973faf2ec30b48e831c'))

    if (status_code(response) == 200) {
      output = response %>%
        content(as = 'text', encoding = 'UTF-8') %>%
        fromJSON() %>%
        getElement(name = 'download_url')
      candidates = output[str_detect(output, ".json$")] %>% na.omit

      if (!is_empty(candidates)) {
        #pkg_name = strsplit(parsed_link, split = "/") %>% unlist()
        #candidate = candidates[str_detect(candidates, pkg_name[2])]
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

      try({
        download.file(url = candidate[1],
                      destfile = str_c("./data/oss/original/CDN/CDN_json/", pkg, ".json"))
        found = TRUE
        }
          ,silent = TRUE)


    } else {
      candidates = c("/master/package.json",
                     "/gh-pages/package.json",
                     "/master/bower.json",
                     "/gh-pages/bower.json")

      for (candidate in candidates) {
        xxx = str_c("https://raw.githubusercontent.com/",
                    parsed_link,
                    candidate) %>%
          GET()

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
  return(value = data.frame(name = pkg,
                            status = found))
}
#############################################################################################


#parse and save the version and dependencies info,ignore dependency versions
main = function () {
  #do the request
  request_status = apply(X = general_info %>%
                           select(name, repository.url),
                         MARGIN = 1,
                         FUN = request_output)

  result_status = do.call(what = rbind, args = request_status)
  rownames(x = result_status) = NULL
  outfile <- file.path("data/oss/final/CDN/request_status.csv")
  write.csv(result_status, outfile, row.names = FALSE)

  #pull out and store useful data with functions defined previously
  authors = data.frame()
  licenses = data.frame()
  dependencies = data.frame()

  filenames = str_c('./data/oss/original/CDN/CDN_json',
                    list.files(path = './data/oss/original/CDN/CDN_json'),
                    sep = '/')
  filename = './data/oss/original/CDN/CDN_json/TremulaJS.json'
  for(filename in filenames) {
    #print(filename)
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
}


parse_x_license = function(x) {
  output = data.frame(name = x$name,
                      license = x$licenses$type)
  return(value = output)
}
parse_x_license(x)




on.exit(dbDisconnect(conn = xxx))
