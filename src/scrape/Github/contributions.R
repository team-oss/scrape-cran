# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dtplyr)

github_personal_token = '' # Get one from https://github.com/settings/tokens
# Credentials
token = add_headers(token = github_personal_token)

parse_activity = function(activity) {
  activity = activity %>%
    filter(c > 0)
  output = data.table(start_date = as.Date(as.POSIXct(activity$w[1L],
                                                      origin = '1970-01-01')),
                      end_date = as.Date(as.POSIXct(activity$w[length(
                        x = activity$w)],
                        origin = '1970-01-01')),
                      additions = sum(activity$a),
                      deletions = sum(activity$d),
                      commits = sum(activity$c))
  return(value = output)
  }

parse_github_repo = function(slug) {
  baseurl = 'https://api.github.com'
  endpoint = 'repos'
  contributions = 'stats/contributors'
  response = str_c(baseurl,
                   endpoint,
                   slug,
                   contributions,
                   sep = '/') %>%
    GET(add_headers(Authorization = str_c('token ', Github_API_token)))
  basic_information = response %>%
    content(as = 'text') %>%
    fromJSON() %>%
    subset(.$author$type %in% 'User')
  if (is_empty(x = basic_information)) {
    output = data.table(user = NA,
                        slug = slug,
                        start_date = NA,
                        end_date = NA,
                        additions = NA,
                        deletions = NA,
                        commits = NA)
  } else {
    output = data.table(user = basic_information$author$login) %>%
      mutate(slug = slug) %>%
      cbind(map_df(.x = basic_information$weeks,
                   .f = parse_activity))
  }
  return(value = output)
  Sys.sleep(time = 1L)
  }
