# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dtplyr, dplyr)

github_personal_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens
# Credentials
token = add_headers(token = github_personal_token)

urls <- read.csv("~/oss/data/oss/final/PyPI/osi_approved_w_repos.csv")
urls$slugs <- NA
for(i in 1:nrow(urls))
{
  if (is.na(urls$repository[i]))
  {
    urls$slugs[i] <- NA
  } else {
    str <- strsplit(as.character(urls$repository[i]), "github.com/")[[1]][2]
    str1 <- strsplit(as.character(str), "/")[[1]][1]
    str2 <- strsplit(as.character(str), "/")[[1]][2]

    if (is.na(str) || is.na(str1) || is.na(str2))
    {
      urls$slugs[i] <- NA
    } else {
      urls$slugs[i] <- paste(str1, str2, sep = "/")
    }
  }

}

# for (slugs in na.omit(urls$slugs[1:5000]))
# {
#   parse_github_repo(slugs)
# }
# slugs = na.omit(urls$slugs[1:5000])
# output = map_df(.x = slugs,
#                 .f = parse_github_repo)
# output <- output[1:14695,]
# write.csv(output, "~/oss/data/oss/final/PyPI/github_api01.csv")


for (slugs in na.omit(urls$slugs[3435:nrow(urls)]))
{
  parse_github_repo(slugs)
}
slugs = na.omit(urls$slugs[3435:nrow(urls)])
output2 = map_df(.x = slugs,
                .f = parse_github_repo)
write.csv(output2, "~/oss/data/oss/final/PyPI/github_api02.csv")


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
  if(is.na(slug))
  {
    output = data.table(user = NA,
                        slug = slug,
                        start_date = NA,
                        end_date = NA,
                        additions = NA,
                        deletions = NA,
                        commits = NA)
  }
  baseurl = 'https://api.github.com'
  endpoint = 'repos'
  contributions = 'stats/contributors'

  response = str_c(baseurl,
                   endpoint,
                   slug,
                   contributions,
                   sep = '/') %>%
    GET(add_headers(Authorization = str_c('token ', github_personal_token)))
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


o1 <- read.csv("~/oss/data/oss/final/PyPI/github_api01.csv")
o2 <- read.csv("~/oss/data/oss/final/PyPI/github_api02.csv")
all_github <- rbind(o1, o2)
write.csv(all_github, "~/oss/data/oss/final/PyPI/all_github_api.csv")

