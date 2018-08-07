pacman::p_load(sdalr, configr, dplyr, DBI, purrr, stringr, data.table, dtplyr,
               httr, jsonlite)
github_token = ''
headers = add_headers(Authorization = str_c('token ', github_token))

read_julia = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'julia_contributions') %>%
    data.table()
  on.exit(expr = dbDisconnect(conn = conn))
  return(value = output)
}
data = read_julia()
until = max(data$end_date, na.rm = TRUE)
slugs = data %>%
  filter(!is.na(x = commits)) %>%
  pull(var = slug) %>%
  unique()

github_commits_contributors = function(slug, until) {
  response = str_c('https://api.github.com/repos/',
                   slug,
                   '/commits?until=',
                   until) %>%
    GET(headers)
  if (is_null(x = response$headers$link)) {
    commits = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow()
  } else {
    url = str_extract(string = response$headers$link,
                      pattern = str_c('(?<=, <).*(?=>; rel="last")'))
    base = str_extract(string = url,
                       pattern = '\\d+$') %>%
      as.integer()
    base = (base - 1L) * 30L
    response = GET(url = url, headers)
    commits = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow() + base
  }
  response = str_c('https://api.github.com/repos/',
                   slug,
                   '/contributors?anon=false&until=',
                   until) %>%
    GET(headers)
  if (is_null(x = response$headers$link)) {
    contributors = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow()
  } else {
    url = str_extract(string = response$headers$link,
                      pattern = str_c('(?<=, <).*(?=>; rel="last")'))
    base = str_extract(string = url,
                       pattern = '\\d+$') %>%
      as.integer()
    base = (base - 1L) * 30L
    response = GET(url = url, headers)
    contributors = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow() + base
  }
  output = data.table(slug = slug,
                      until = until,
                      commits = commits,
                      contributors = contributors)
  if (as.integer(x = response$headers$`x-ratelimit-remaining`) < 5L) {
    Sys.sleep(time = 3.6e3)
  }
  return(value = output)
  }

output = map2_df(.x = slugs,
                 .y = until,
                 .f = github_commits_contributors)

upload_julia_contributors_commits = function(data) {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbWriteTable(conn = conn,
                        name = 'julia_contributors_commits',
                        value = data,
                        row.names = FALSE,
                        overwrite = TRUE) %>%
    data.table()
  on.exit(dbDisconnect(conn = conn))
  return(value = output)
  }
upload_julia_contributors_commits(data = output)
