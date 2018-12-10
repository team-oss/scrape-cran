library(stringr)
library(httr)
library(magrittr)
library(jsonlite)
library(data.table)
library(dtplyr)
library(purrr)

#' Returns the JSON reponse from the repos/stats/contributors endpoint for a github user/repo slug
#' This function makes the actual API call so the results should be saved right away to prevent over querrying the API
get_github_contributions <- function(slug, baseurl = 'https://api.github.com',
                                     endpoint = 'repos',
                                     contributions = 'stats/contributors',
                                     gh_token = Sys.getenv('GH_TOSS_TOKEN')) {
  if (is.na(slug)) {return(NA)}

  response = stringr::str_c(baseurl,
                            endpoint,
                            slug,
                            contributions,
                            sep = '/') %>%
    GET(add_headers(Authorization = str_c('token ', gh_token)))
  basic_information = response %>%
    content(as = 'text') %>%
    fromJSON()
  return(basic_information)
}

#' Helper function that takes the week information from get_github_contributions and returns contribution values
#' This function does not querry the API.
parse_activity = function(activity) {
  #print(class(activity))
  activity = activity %>%
    dplyr::filter(c > 0)
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

#' Takes the results from get_github_contributions and returns a dataframe of contribution values by user.
#' This function does not querry the API.
parse_github_contributions_results <- function(dat, slug) {
  # dat <- contributions
  # slug <- 'numpy/numpy'
  # activity <- basic_information$weeks
  basic_information <- dat %>%
    subset(.$author$type %in% 'User')

  if (purrr::is_empty(x = basic_information)) {
    output = data.table(user = NA,
                        slug = slug,
                        start_date = NA,
                        end_date = NA,
                        additions = NA,
                        deletions = NA,
                        commits = NA)
  } else {
    output = data.table(user = basic_information$author$login) %>%
      dplyr::mutate(slug = slug) %>%
      cbind(map_df(.x = basic_information$weeks,
                   .f = parse_activity))
  }
  return(value = output)

  return(basic_information)
}
