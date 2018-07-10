
# Housekeeping
pacman::p_load(docstring, httr, jsonlite, tidyverse, plyr, data.table)

# LICENCES
licenses = function() {
  output = GET(url = 'https://raw.githubusercontent.com/spdx/license-list-data/master/json/licenses.json') %>%
    content(as = 'text') %>%
    fromJSON() %>%
    getElement(name = 'licenses') %>%
    select(name, licenseId, isOsiApproved) %>%
    data.table() %>%
    setnames(old = 'licenseId', new = 'id') %>%
    setnames(old = 'isOsiApproved', new = 'osi')
  con = con_db(pass = get_my_password())
  dbWriteTable(con = con,
               'licenses',
               output,
               row.names = FALSE,
               overwrite = TRUE)
  on.exit(dbDisconnect(con))
}
licenses()

LICENSES = GET(url = 'https://raw.githubusercontent.com/spdx/license-list-data/master/json/licenses.json') %>%
  content(as = 'text') %>%
  fromJSON() %>%
  getElement(name = 'licenses') %>%
  mutate(keyword = mapvalues(x = licenseId,
                             from = c('CC0-1.0'),
                             to = c('CC0 1.0 Universal')))
# Credentials
token = add_headers(token = '2161ca3e8ab029650c23bb5941c6ebdb5c2d90f2')

parse_license(license = chk2)
repository = basic_information$Repositories[1]
chk = basic_information %>%
  filter(Owner != 'Julia')
github = function(repository) {
  #' Pull the information of interest for a Github repository.
  #'
  #' @description Obtain useful information from a Github repository.

  #' @usage github(repo)
  #' @usage github(repo, licence = TRUE)
  #' @return data.table with information.

  # Helper
  parse_license = function(license) {
    idx = 1L
    for (l in LICENSES$keyword) {
      if (grepl(pattern = l, license)) {
        return(LICENSES$licenseId[idx])
      }
      idx = idx + 1L
    }
    return('Unknown license')
  }

  # repository = str_extract(string = 'https://github.com/JuliaIO/SerialPorts.jl',
  #                          pattern = '(?<=github.com/).*')
  # repository = str_extract(string = 'https://github.com/Nosferican/NCEI.jl',
  #                          pattern = '(?<=github.com/).*')
  # repository = str_extract(string = 'https://github.com/https://github.com/boostorg/random',
  #                          pattern = '(?<=github.com/).*')
  repository = str_extract(string = repository,
                           pattern = '(?<=github.com/).*')

  basic_information$Name[grepl(pattern = 'deprecated',
        x = basic_information$Description,
        ignore.case = TRUE) %>%
    which()]

  Deprecated
  url = str_c('https://api.github.com/repos/', repository)
  response = GET(url = url,
                 token)
  stop_for_status(response)
  json = response %>%
    content(as = 'text') %>%
    fromJSON()
  License = json$license$spdx_id
  if (is.null(x = License)) {
    License = str_c(url, '/license') %>%
      GET(token) %>%
      content(as = 'text') %>%
      fromJSON()
    tryCatch({
      stop_for_status(x = response)
      License = GET(url = License$download_url) %>%
        content(as = 'text') %>%
        parse_license()
    },
    error = function(cond) {
      License = 'Failed to parse'
    }
    )
  }
  return(License)
}

Woot = github(chk$Repositories[2])

  if (json$license$key == 'other') {


    tryCatch(stop_for_status(response),
             http_404 = function(c) "That url doesn't exist",
    print(0)
    )
  }


    %>%
      content(as = 'text') %>%
      parse_license()

    chk2 = response %>%

    for (l in LICENCES) {

    }
  }
  chk = basic_information %>%
    filter(Licence == 'Unknown license ')
  response = GET(url = url,
                 token)
  stop_for_status(response)

}
?github

Repository = basic_information$Repositories[1]


url = 'https://api.github.com'
url = 'https://api.github.com/users/nosferican/repos'
url = 'https://api.github.com/orgs/JuliaStats'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/contributors'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/stats/contributors'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/stats/contributors'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/collaborators/:username/permission'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/collaborators'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/license'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/releases'
url = 'https://api.github.com/repos/JuliaStats/StatsBase.jl/releases/11259593'

url
# Use API
response = GET(url = url,
               token)
response = GET(url = url2,
               token)

#### What up ####


response
url =

stop_for_status(response)
RCurl::base64(txt = json$content)
json = response %>%
  content(as = 'text') %>%
  fromJSON()
L = response %>%
  content(as = 'text')
L
OSI_approved =

url2 = json$download_url

json$assets_url
url = json$assets_url[1]
json
total = json$total %>%


  dplyr::filter(type == 'User') %>%
  getElement(name = 'login')
users = json$author$type == 'User'
weeks = lapply(X = json$weeks[users], FUN = function(df) {
  with(df,
       data.table(Start = as.Date(as.POSIXct(w[1], origin = '1970-01-01')),
                  End = as.Date(as.POSIXct(w[nrow(df)], origin = '1970-01-01')),
                  a = sum(a),
                  d = sum(d),
                  c = sum(c)))
})
weeks = do.call(what = rbind, args = weeks)
output = cbind(data.table(Author = json$author$login[users]), weeks)

json2 = plyr::ddply(.data = json %>%
                      select(weeks, ), .variables = )
json$weeks[[1]]
endpoints = data.table(ID = names(x = json),
                       endpoint = json)
  data.table()

?content
# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

?stop_for_status
parse(response$content)
?GET

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
gitDF[gitDF$full_name == 'jtleek/datasharing', 'created_at']


# Housekeeping
pacman::p_load(docstring, httr, jsonlite, stringr, data.table, dtplyr)

github_personal_token = '2161ca3e8ab029650c23bb5941c6ebdb5c2d90f2' # Get one from https://github.com/settings/tokens
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

# slug = 'JuliaStats/StatsBase.jl' # Change the slug to the owner/repo form

parse_github_repo = function(slug) {
  baseurl = 'https://api.github.com'
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

output = parse_github_repo(slug = slug)

