# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dtplyr, purrr)

github_personal_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens
# Credentials
token = add_headers(token = github_personal_token)

parser = function(idx) {
  activity = basic_information$weeks[[idx]] %>%
    filter(c > 0L)
  time_period = activity$w
  adc = colSums(activity[,2:4])
  output = data.table(slug = slug,
                      contributor = basic_information$author$login[idx],
                      start_date = as.Date(as.POSIXct(time_period[1L],
                                                      origin = '1970-01-01')),
                      end_date = as.Date(as.POSIXct(time_period[length(
                        x = time_period)],
                        origin = '1970-01-01')),
                      additions = adc[1L],
                      deletions = adc[2L],
                      commits = adc[3L])
  return(value = output)
}

parse_github_repo = function(slug) {
  baseurl = 'https://api.github.com/'
  endpoint = 'repos'
  contributions = 'stats/contributors'
  response = str_c(baseurl,
                   endpoint,
                   slug,
                   contributions,
                   sep = '/') %>%
    GET(token)
  basic_information = response %>%
    content(as = 'text') %>%
    fromJSON()
  output = map_df(.x = 1L:nrow(x = basic_information),
                  .f = parser)
  return(value = output)
}

urls <- read.csv("~/oss/data/oss/final/PyPI/osi_approved_w_repos.csv")
urls$slugs <- NA
for(i in 1:nrow(urls))
{
  urls$slugs[i] <- strsplit(as.character(urls$repository[i]), "github.com/")[[1]][2]
}

res <- parse_github_repo(urls$slugs[365])

#output = parse_github_repo(slug = slug)
