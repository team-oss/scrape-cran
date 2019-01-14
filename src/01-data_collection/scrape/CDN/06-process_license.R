#parse license info in the first round

#libraries
library(data.table)
library(stringr)
library(dplyr)
library(jsonlite)
library(DBI)
library(sdalr)

# functions

#roughly extract the licenses of a package
#filename is a json file's name
#returns a df with col 1 as package name, col 2 as licenses
#col 2 can contain subcolumns
parse_license <- function(filename) {
  #extract package name
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN/CDN_json/).*') %>%
    str_remove(".json$")

  #load json file
  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()

  #try to create a df; if there is any issue, return a 1*2 df with
  #col 1 as package name, col 2 as license (NA)
  tryCatch({
    df <- as.data.frame(json_file$license)
    if (df[[1]] == "") {
      df[[1]] = NA
    }
    df$pkg_name <- pkg_name
    return(df)
  }, error = function(e){
    return(data.frame('pkg_name' = pkg_name, 'license' = NA))
  })

}

#pick and collapse the licenses for a package
#licence_dat is a df, where licenses can be under different columns
pick_license <- function(licence_dat) {
  #extract licenses with priority
  if (!is.na(licence_dat['json_file$license'])) {
    return(licence_dat['json_file$license'])
  } else if (!is.na(licence_dat['type'])){
    return(licence_dat['type'])
  } else if (!is.na(licence_dat['license'])){
    return(licence_dat['license'])
  } else if (!is.na(licence_dat['name'])){
    return(licence_dat['name'])
  } else {
    return(NA)
  }
}


#############################################################################################
# script
#load all json file names
filenames = str_c('./data/oss/original/CDN/CDN_json',
                  list.files(path = './data/oss/original/CDN/CDN_json'),
                  sep = '/')

#extract licenses
licenses_list <- lapply(X = filenames, FUN = parse_license)

dt <- rbindlist(licenses_list, fill = TRUE)

#pick licenses
dt$license_selected <- apply(dt, MARGIN = 1, pick_license)

dt_filtered <- dt[, c('pkg_name', 'license_selected')]

#reformat
name(dt_filtered) = c("name", "license")

#upload result
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CDN_licenses_info",
             value = dt_filtered,
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))