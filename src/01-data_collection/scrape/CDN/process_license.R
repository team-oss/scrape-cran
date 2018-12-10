library(data.table)
library(stringr)
library(dplyr)
library(jsonlite)
library(DBI)
library(sdalr)
# functions
parse_license_info <- function(filename) {
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN/CDN_json/).*') %>%
    str_remove(".json$")
  # pkg_name

  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()

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

pick_license <- function(licence_dat) {
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

# script
filenames = str_c('./data/oss/original/CDN/CDN_json',
                  list.files(path = './data/oss/original/CDN/CDN_json'),
                  sep = '/')

licenses_list <- lapply(X = filenames, FUN = parse_license_info)

dt <- rbindlist(licenses_list, fill = TRUE)

dt$license_selected <- apply(dt, MARGIN = 1, pick_license)

dt_filtered <- dt[, c('pkg_name', 'license_selected')]

name(dt_filtered) = c("name", "license")

my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CDN_licenses_info",
             value = dt_filtered,
             row.names = FALSE,
             overwrite = TRUE)
