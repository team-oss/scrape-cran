library(data.table)
library(stringr)
library(dplyr)
library(jsonlite)
library(DBI)
library(sdalr)

general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
owner <- general_info[,'repository.url']

# functions
#parse single author and email
parse_author_email = function(x) {
  result = data.frame()
  if (is(x, "character")) {
      author_names = str_extract(string = x,
                                 pattern = '^.*?(?=\\s\\<|\\(|$)')
      if (!grepl("[[:alpha:]]", author_names[1]) & !grepl("[[:digit:]]", author_names[1])) {
        author_names = NA
      }
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
parse_author_info = function (filename) {

  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN/CDN_json/).*') %>%
    str_remove(".json$")
    # pkg_name

  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()

  if (is.null(json_file$author) & is.null(json_file$authors)) {
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

# script
filenames = str_c('./data/oss/original/CDN/CDN_json',
                  list.files(path = './data/oss/original/CDN/CDN_json'),
                  sep = '/')

author_list <- lapply(X = filenames[67], FUN = parse_author_info)

dt <- rbindlist(author_list, fill = TRUE)

dt_reordered <- dt[,c('name', 'author', 'email')]

my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CDN_authors_info",
             value = dt_reordered,
             row.names = FALSE,
             overwrite = TRUE)
