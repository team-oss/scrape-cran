#parse author info in the first round

#libraries
library(data.table)
library(stringr)
library(dplyr)
library(jsonlite)
library(DBI)
library(sdalr)
source("functions_keren.R")

#############################################################################################
# script

#load up general info
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
owner <- general_info[,'repository.url']

#load all json file names
filenames = str_c('./data/oss/original/CDN/CDN_json',
                  list.files(path = './data/oss/original/CDN/CDN_json'),
                  sep = '/')

#apply the parsing function
author_list <- lapply(X = filenames, FUN = load_parse_author_info)

#standarlize the format
dt <- rbindlist(author_list, fill = TRUE)

dt_reordered <- dt[,c('name', 'author', 'email')]

#upload result
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CDN_authors_info",
             value = dt_reordered,
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))
