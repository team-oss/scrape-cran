#scarping cdnjs with provided API
library(rvest)
library(jsonlite)
library(httr)
library(stringr)
library(dplyr)
library(purrr)
library(tidyr)

rm(list = ls())

func = function() {
  response = GET(url = 'https://api.cdnjs.com/libraries/') %>%
    content(as = 'text', encoding = 'UTF-8') %>%
    fromJSON()
  #get all package names
  name = response$results$name

  #request info for each package
  info <- vector(mode = "list", length = length(name))

  for (i in 1:length(name)) {
    print(i)
    #search for repo on GitHub
    info[[i]] <- GET(url = str_c("https://api.cdnjs.com/libraries/", name[i])) %>%
      content(as = 'text', encoding = 'UTF-8') %>%
      fromJSON()

    Sys.sleep(runif(1) * 0.2)
  }

  # lapply(X = info, FUN = names) %>%
  #   unlist() %>%
  #   unique()
  # })

  columns = c("name", "description", "homepage", "keywords",
              "repository", "license", "licenses", "author", "authors")

  magic = function(arg) {
    #arg = info[[1469]]
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
      #how to solve?
      arg$keywords <- c(NA)
    }
    #info[[1469]] fails the whole
    output = as.data.frame(arg[names(arg) %in% columns],
                           stringsAsFactors = FALSE)
    return(output)
  }

  #this one works
  output = map_df(.x = info,
                  .f = magic)

  # magic(info[[150]])
  # info[[2]]$keywords
  # rm(output)
  # bind_rows(data.frame(name = vector(mode = 'character'), Repository = 'My Lair'),
  #           output)
  # Names = c('name', 'repository')
  # magic = function(pkg) {
  #   pkg = info[[1]]
  #   output = as.data.frame(pkg[names(pkg) %in% Names], stringsAsFactors = FALSE)
  #
  # }



  #save RDS
  saveRDS(info, file = 'data/oss/working/CDN/raw_response.RDS')
  #df = data.frame("Name" = name, "Category" = category)
  outfile <- file.path("data/oss/working/CDN/raw_response.csv")
  write.csv(output, outfile, row.names = FALSE)

}

func()
