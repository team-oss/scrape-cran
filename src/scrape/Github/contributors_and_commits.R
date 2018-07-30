pacman::p_load(sdalr, configr, dplyr, DBI, purrr, stringr, data.table, dtplyr,
               httr, jsonlite)
github_token = '' # your Github API token
# data = data.table() #  where data is the contributors data
#until = today() # this should be max(data$end_date)
# slugs = vector(mode = 'character') # this should be unique(data$slugs)
headers = add_headers(Authorization = str_c('token ', github_token))

github_commits_contributors = function(slug, until) {
  response = str_c('https://api.github.com/repos/',
                   slug,
                   '/commits?until=',
                   until) %>%
    GET(headers)
  url = str_extract(string = response$headers$link,
                    pattern = str_c('(?<=, <).*(?=>; rel="last")'))
  base = str_extract(string = url,
                     pattern = '\\d+$') %>%
    as.integer()
  if (base %in% 1L) {
    commits = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow()
  } else {
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
  url = str_extract(string = response$headers$link,
                    pattern = str_c('(?<=, <).*(?=>; rel="last")'))
  base = str_extract(string = url,
                     pattern = '\\d+$') %>%
    as.integer()
  if (base %in% 1L) {
    contributors = response %>%
      content(as = 'text',
              encoding = 'UTF-8') %>%
      fromJSON() %>%
      nrow()
  } else {
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
                      contributors)
  return(value = output)
}

output = map_df(.x = slugs,
                .f = github_commits_contributors)
