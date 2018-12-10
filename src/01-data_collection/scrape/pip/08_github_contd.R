# INPUT:
#        "~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv"
# OUTPUT:
#        "~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv"

osi_production_mature <- read.csv("~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv")
osi_production_mature$slugs <- NA
osi_production_mature$stars <- NA


pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dtplyr, dplyr, purrr)
github_personal_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens
token = add_headers(token = github_personal_token)

for(i in 1:nrow(osi_production_mature))
{
  if (is.na(osi_production_mature$repository[i]))
  {
    osi_production_mature$slugs[i] <- NA
  } else {
    str <- strsplit(as.character(osi_production_mature$repository[i]), "github.com/")[[1]][2]
    str1 <- strsplit(as.character(str), "/")[[1]][1]
    str2 <- strsplit(as.character(str), "/")[[1]][2]

    if (is.na(str) || is.na(str1) || is.na(str2))
    {
      osi_production_mature$slugs[i] <- NA
    } else {
      osi_production_mature$slugs[i] <- paste(str1, str2, sep = "/")
    }
  }
}

for (i in 1:nrow(osi_production_mature))
{
  slug = osi_production_mature$slugs[i]
  if(is.na(slug))
  {
    osi_production_mature$stars[i] <- NA
    next
  }
  baseurl = 'https://api.github.com'
  endpoint = 'repos'

  response = str_c(baseurl,
                   endpoint,
                   slug,
                   sep = '/') %>%
    GET(add_headers(Authorization = str_c('token ', github_personal_token)))

  basic_information = response %>%
    content(as = 'text') %>%
    fromJSON()

  if (is_empty(x = basic_information)) {
    osi_production_mature$stars[i] <- NA
  } else if (!is.null(basic_information$stargazers_count)) {
    osi_production_mature$stars[i] <- basic_information$stargazers_count
  }

}

write.csv(osi_production_mature, "~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv")
