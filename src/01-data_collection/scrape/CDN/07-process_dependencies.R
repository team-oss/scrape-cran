#parse dependencies for each package

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

#load file names
filenames = str_c('./data/oss/original/CDN_json',
                  list.files(path = './data/oss/original/CDN_json'),
                  sep = '/')

#apply function
denpendencies_list <- lapply(X = filenames, FUN = load_parse_denpendency_info)

#reformat
dt <- rbindlist(denpendencies_list, fill = TRUE)
dt_reordered <- dt[,c('name', 'version', 'dependency')]

#extract the dependency package names, and add those names into package names column as new entries
#only retain unique rows
extra_names = setdiff(unique(dt_reordered$dependency), unique(dt_reordered$name))
extra_rows = data.frame(name = extra_names, version = NA, dependency = NA)
dt_reordered = rbind(dt_reordered, extra_rows)

#upload result
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_dependencies_info",
             value = dt_reordered,
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))