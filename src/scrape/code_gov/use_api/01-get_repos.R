library(httr)

# stuffs <- httr::GET('http://code-api.app.cloud.gov/api/repos',
#                     query = list(
#                       'size' = '10'
#                     ),
#                     add_headers(
#                       'accept' = 'application/json',
#                       'X-Api-Key' = sdalr::get_code_gov_key()
#                     ))

#' Pulls repositories from the code.gov api
get_repos <- function(base_url = 'http://code-api.app.cloud.gov/api/repos',
                      size_per_request = 2,
                      page_num = 0,
                      key = sdalr::get_code_gov_key()) {
  res <- httr::GET(base_url,
                   query = list(
                     'size' = size_per_request
                   ),
                   add_headers(
                     'accept' = 'application/json',
                     'X-Api-Key' = sdalr::get_code_gov_key()
                   ))
  return(res)
}


next_page <- TRUE
page_num <- 0
size_per_request <- 500


repos <- get_repos(size_per_request = size_per_request)
con <- content(repos)

l <- lapply(con$repos, data.frame, stringsAsFactors = FALSE)

dt <- data.table::rbindlist(l, fill = TRUE)

# while (next_page) {
#
#   repos <- get_repos(size_per_request = size_per_request)
#   con <- content(repos)
#
#   l <- lapply(con$repos, data.frame)
#
#   dt <- data.table::rbindlist(l, fill = TRUE)
#
#   if (repos$status_code != 200) {
#     next_page <- FALSE
#   }
#   page_num = page_num + 1
# }

saveRDS(dt, './data/oss/original/code_gov/api_pull/repo_contents.RDS')
