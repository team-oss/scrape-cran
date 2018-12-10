pacman::p_load(sdalr, DBI, stringr, dplyr, data.table, dtplyr, purrr)

read_cran = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'CRAN_OSI_CI_passing') %>%
    data.table()
  on.exit(expr = dbDisconnect(conn = conn))
  return(value = output)
  }
parse_deps = function(name, deps) {
  deps = deps %>%
    str_split(pattern = ',') %>%
    unlist() %>%
    str_trim() %>%
    subset(!str_detect(string = .,
                       pattern = '^R ')) %>%
    str_remove_all(pattern = '\\s.*') %>%
    str_trim()
  if (is_empty(x = deps) || is.na(x = deps)) {
    output = data.table(name = name,
                        dependencies = NA)
  } else {
    output = data.table(name = name,
                        dependencies = deps)
  }
  return(value = output %>%
           mutate(name = str_remove(string = name,
                                    pattern = ':.*')))
}
dependencies = read_cran()

output = with(dependencies,
              map2_df(.x = name,
                      .y = Depends.,
                      .f = parse_deps))
write_dependencies = function(data) {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  dbWriteTable(conn = conn,
               name = 'cran_dependencies',
               value = data,
               row.names = FALSE,
               overwrite = TRUE)
  on.exit(dbDisconnect(conn = conn))
  }
write_dependencies(data = output)
