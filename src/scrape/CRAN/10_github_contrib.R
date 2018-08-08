#get data ready for analysis!
#load in the data we wanna use
cran <- readRDS('./data/oss/working/CRAN_2018/OSI_CI_GITHUB_SLUGS.RDS')

length(unique(cran))
pacman::p_load(sdalr, configr, dplyr, DBI, purrr, stringr, data.table, dtplyr,
               httr, jsonlite)
github_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # your Github API token
# github_token = '5e4c1e4b46d9dfdcd659da4f0c45d444200a2b73' # your Github API token
# data = data.table() #  where data is the contributors data
#until = today() # this should be max(data$end_date, na.rm = TRUE)
# slugs = vector(mode = 'character') # this should be unique(data$slugs)
headers = add_headers(Authorization = str_c('token ', github_token))

github_commits_contributors = function(slug, until){
  response = str_c('https://api.github.com/repos/',
                   slug,
                   '/commits?until=',
                   until) %>%
    GET(headers)
  if(response$status_code != 200){
    return(data.table(slug = slug,
                      until = until,
                      commits = NA,
                      contributors=NA))
  }
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
  if(is.null(contributors)){
    contributors = 0
  }
  output = data.table(slug = slug,
                      until = until,
                      commits = commits,
                      contributors)
  if (as.integer(x = response$headers$`x-ratelimit-remaining`) < 5L) {
    Sys.sleep(time = 3.6e3)
  }
  return(value = output)
}

#date we will be using in the function
today <- '2018-07-31T00:00:00Z'
#test it out
github_commits_contributors(cran[2663], today)

#run for real
output = map2_df(.x = cran,
                 .y = today,
                 .f = github_commits_contributors)

# #works here so far
# for(i in 2663:length(cran)){
#   github_commits_contributors(cran[i],today)
#   print(i)
# }
