library(data.table)
library(stringr)
library(dplyr)
library(jsonlite)
library(DBI)
library(sdalr)

# functions
parse_denpendency_info = function (filename) {
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN_json/).*') %>%
    str_remove(".json$")
  # pkg_name

  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()

  version = json_file$version
  dependency = json_file$devDependencies %>% names
  if (is.null(version)) {
    version = NA
  }

  tryCatch({
    df <- as.data.frame(dependency)
    # if (df[[1]] == "") {
    #   df[[1]] = NA
    # }
    df$version <- version
    df$name <- pkg_name
    return(df)
  }, error = function(e){
    return(data.frame('pkg_name' = pkg_name, 'version' = version, "dependency" = NA))
  })
}

# script
filenames = str_c('./data/oss/original/CDN_json',
                  list.files(path = './data/oss/original/CDN_json'),
                  sep = '/')

denpendencies_list <- lapply(X = filenames, FUN = parse_denpendency_info)


dt <- rbindlist(denpendencies_list, fill = TRUE)
dt_reordered <- dt[,c('name', 'version', 'dependency')]

extra_names = setdiff(unique(dt_reordered$dependency), unique(dt_reordered$name))
extra_rows = data.frame(name = extra_names, version = NA, dependency = NA)
dt_reordered = rbind(dt_reordered, extra_rows)


my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_dependencies_info",
             value = dt_reordered,
             row.names = FALSE,
             overwrite = TRUE)
