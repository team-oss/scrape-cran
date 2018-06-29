#temporary fix for github information
# we missed a couple of Cran packages in cleaning. we have them now so we need to run them through github API functions

#load our list of keys, and identify the set of packages that we have missed
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS')
Analysis <- readRDS('./data/oss/working/CRAN_2018/Analysis.RDS')
missed <- setdiff(keys$slug, Analysis$slug) #this should be 220 packages

######helper functions from bayoan------
# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dplyr, dtplyr, purrr)

# github_personal_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens
# github_token = '1c06459fc9b515e2a5aa748b06913f3495068a45' # Get one from https://github.com/settings/tokens

github_personal_token = '5e4c1e4b46d9dfdcd659da4f0c45d444200a2b73' # Get one from https://github.com/settings/tokens
github_token= '5e4c1e4b46d9dfdcd659da4f0c45d444200a2b73' # Get one from https://github.com/settings/tokens

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


###### re run the github api on top 100 contributors ------
x <- data.table(map_df(.x = missed, .f = parse_github_repo))
###### re run the github api on all commits / contributors
today <- '2018-07-31T00:00:00Z' #note that this 'today' still needs to be fixed : make a vector of each max date


output = map2_df(.x = missed,
                 .y = today,
                 .f = github_commits_contributors)


top100 <- x[complete.cases(x)]
all_contrib <- output[complete.cases(output)]
#calculate lines of code
byPack <- group_by(top100, slug)
#now display sum of adds and deletes
top100_data <- byPack %>% summarise(
  adds = sum(additions),
  dels = sum(deletions),
  commits = sum(commits)
)
top100_data$lines_of_code <- top100_data$adds + top100_data$dels
top100_data$kloc <- top100_data$lines_of_code /1000

#append this information to analysis by making another table and rbind
###### new Analysis -----
helping <- top100
help_dates <- group_by(helping, slug)%>% summarise(mindate=min(start_date),maxdate=max(end_date))
help_table <- data.frame(table(helping$slug))
colnames(help_table) <- c("slug","freq")
help_table$slug <- as.character(help_table$slug)

#migh wanna change these variable names
Loc <- top100_data
contrib <- all_contrib

last_set <- full_join(Loc,contrib, by= "slug")
last_set <- full_join(last_set,help_table,by='slug',copy=T)
last_set <- full_join(last_set,help_dates,by='slug')


#Important cleaning step: only taking complete cases of the join.
# I choose to do this because I know the github contribution data is OSI CI passing,
# but the Lines of Code data is just all github. So when contribution data is missing, get rid of the
# entire row

last_set <-  last_set[complete.cases(last_set),]

analysis <- data.table(matrix(nrow = nrow(last_set),ncol = 10))
colnames(analysis) <- c("registry","slug","start_date","end_date","kloc","commits","num_of_contributors",
                        "all_contributors","all_commits","major_contributors")
#make all registry R
analysis$registry <- (rep("R",nrow(last_set)))

#fill slugs
analysis$slug <- last_set$slug

#make all start date
analysis$start_date <- last_set$mindate
analysis$end_date <- last_set$maxdate
#fill kloc
analysis$kloc <- last_set$kloc

#fill commits
analysis$commits <- last_set$commits.x

#fill num contrib
analysis$num_of_contributors <- last_set$freq

#fill all contrib
analysis$all_contributors <- last_set$contributors

#major contributors - if >5% of code add one to count
top100$maj <- c(0)

top100$user_kloc <- (top100$additions+top100$deletions) / 1000
pkg_loc <- full_join(top100,top100_data,by='slug')
pkg_loc <- select(pkg_loc, slug, kloc)
colnames(pkg_loc) <- c("slug", "pkg_kloc")
pkg_loc <- unique( pkg_loc[ , 1:2 ] ) # de duplicate
top100 <- full_join(top100,pkg_loc,by='slug')
#this loop determines if a user is a major contributor or not - 1 if yes 0 if no
for(i in 1:nrow(top100)){
  if((top100$user_kloc[i] / top100$pkg_kloc[i]) > 5e-2){
    top100$maj[i] = 1
  }
}
#groupby and determine
bymajor_contrib <- group_by(top100, slug)
major_vec <- bymajor_contrib %>% summarise(
  maj = sum(maj)
)

analysis$major_contributors <- select(left_join(analysis,major_vec,by='slug'),'maj')

#all_commits
analysis$all_commits <- last_set$commits.y

#save
#saveRDS(analysis, './data/oss/working/CRAN_2018/quick_fix_analysis.RDS')

#bind with full analysis table
big_analysis <- readRDS('./data/oss/working/CRAN_2018/Analysis.RDS') #note major contributors not fixed fully yet
outs <- rbind(big_analysis,analysis,fill=T)

#write out again
#saveRDS(outs, './data/oss/working/CRAN_2018/quick_fix_analysis_table.RDS')
library(sdalr)
library(DBI)
library(data.table)
#write to database
# my_db_con <- con_db("oss", pass=sdalr::get_my_password())
# dbWriteTable(con = my_db_con,
#              name = "CRAN_analysis",
#              value = outs,
#              row.names = FALSE,
#              overwrite = TRUE)
