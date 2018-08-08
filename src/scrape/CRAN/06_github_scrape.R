# github scraping from bayoan

source('./src/scrape/Github/Contribution Script.R')

# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dplyr, dtplyr, purrr)

github_personal_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens
#github_personal_token = '5e4c1e4b46d9dfdcd659da4f0c45d444200a2b73' # Get one from https://github.com/settings/tokens

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
    GET(add_headers(Authorization = str_c('token ', github_personal_token)))
  print(str_c(slug, status_code(x = response), sep = ' '))
  if(status_code(response) == 204){
    output = data.table(user = NA,
                        slug = slug,
                        start_date = NA,
                        end_date = NA,
                        additions = NA,
                        deletions = NA,
                        commits = NA)
  }else {
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
  }
  return(value = output)
  Sys.sleep(time = 2L)
}

library(stringr)
library(data.table)
library(tidyr)


#### MY STUFF
data <- readRDS(file = './data/oss/working/CRAN_2018/Cran_full_table.RDS')
URL <- data$'URL:'
safety_net <- data$'BugReports:' #taking bug reports link if it is a github.io link

real_data <- data.table(cbind(URL,safety_net))
#drop row if URL column is NA
real_data <- drop_na(real_data, URL)
#take out spaces and commas
real_data$URL <- str_replace_all(real_data$URL,",.*","")
real_data$URL <- str_replace_all(real_data$URL,"\\s.*","")
#filter github urls
real_data <- real_data[stringr::str_detect(real_data$URL,'github')]

real_data$slug <- seq(1:nrow(real_data))
real_data$slug <- as.character(real_data$slug)
#replace .io with real slug, take out anything not a github link
for(i in 1:nrow(real_data)){
  name <- real_data$URL[i]
  help <- real_data$safety_net[i]
  if(str_detect(name, '\\.io') || !str_detect(name,"\\//github.com")){
    name <- help
  }
  #replace slug with the issues link, if available
  name <- str_remove(name,"/$")
  name <- str_remove(name,"\\/issues")
  real_data$slug[i] <- name
}

#get slug vector
slugs <- real_data$slug
#omit na, and then get the parsed slug
slugs <- str_replace_all(slugs,".*github.com/","")
slugs <- str_replace_all(slugs, "/$","")
slugs <- na.omit(slugs)
# only use this for loop for checking promises. can lock you out
# for(i in 1:length(slugs)){
#   if (i %% 100 ==0){
#     print(i)
#   }
#   datas = slugs[i]
#   parse_github_repo(slug = datas)
# }
#run the function
x <- data.table(map_df(.x = slugs, .f = parse_github_repo))
#use to write out
#saveRDS(x, './data/oss/original/CRAN_2018/cran_git.RDS')

#just run the script on the NA repos, then rbind them back into the data
cran_git <- readRDS('./data/oss/original/CRAN_2018/cran_git.RDS')
bad_rows <- cran_git[is.na(cran_git$user)]
cran_git <- cran_git[!is.na(cran_git$user)]
new_slugs <- str_extract_all(bad_rows$slug,".+?\\/([a-zA-Z0-9]+)","")
new_slugs <- new_slugs[,1]
new_slugs <- na.omit(new_slugs)

y <- data.table(map_df(.x = new_slugs, .f = parse_github_repo))

#combine the data sets and write out
dats <- rbind(cran_git,y)
#saveRDS(dats, './data/oss/original/CRAN_2018/cran_git_cleaner.RDS')
