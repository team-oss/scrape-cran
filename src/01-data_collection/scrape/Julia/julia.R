# Julia

# Housekeeping
pacman::p_load(docstring, httr, rvest, tidyverse, data.table, dtplyr, jsonlite)

# Helpers
pass = function(name) {
  url = str_c('https://pkg.julialang.org/logs/', name, '_0.6.log')
  response = GET(url = url) %>%
    content(as = 'text')
  grepl(pattern = str_c(name, ' tests passed'), x = response)
}
something_works = function(name) {
  #' Has the package ever worked with any currently supported versions?
  #'
  #' @description Verifies if any release passed its tests for Julia 0.6.

  #' @usage something_works(name)
  #' @return logit indicator
  grepl(pattern = 'Tests pass',
        x = GET(url = str_c('https://pkg.julialang.org/detail/',
                            name)) %>%
          content(as = 'text') %>%
          str_remove_all(pattern = '\n') %>%
          str_extract(pattern = '(?<=<h4>Julia v0.6</h4>\\s{4}<pre>).*(?=</pre>\\s{8}<h4>)'))
}
stable_last = function(repo) {
  #' Does the last working build job (within the last 25 jobs) include 0.6?
  #'
  #' @description Has it passed with Julia 0.6.

  #' @usage stable_last(name)
  #' @return logit indicator
  repo = str_extract(string = repo,
                     pattern = '(?<=.com/).*.jl?')
  if (is.na(x = repo)) {
    return(FALSE)
  }
  builds = GET(url = str_c('https://api.travis-ci.org/repos/', repo, '/builds'),
               add_headers(c(Accept = 'application/json',
                             Authorization = 'token DRt1TjjDmPG4wX8bq0YqVg'))) %>%
    content(as = 'text', encoding = 'UTF-8') %>%
    fromJSON()
  if (is_empty(x = builds)) {
    return(FALSE)
  }
  builds = builds %>%
    filter(result == 0L)
  if (is_empty(x = builds)) {
    return(FALSE)
  }
  builds = builds %>%
    head(1L) %>%
    getElement(name = 'id')
  output = '0.6' %in%
    (GET(url = str_c('https://api.travis-ci.org/builds/', builds),
         add_headers(c(Accept = 'application/json',
                       Authorization = 'token DRt1TjjDmPG4wX8bq0YqVg'))) %>%
       content(as = 'text', encoding = 'UTF-8') %>%
       fromJSON() %>%
       getElement(name = 'config') %>%
       getElement(name = 'julia'))
  return(output)
}




str_detect(string = 'hola DEPRECATED',
           pattern = '(?i)(deprecated)')

basic_information = function() {
  #' Package name, description, licence, and repository.
  #'
  #' @description Obtains the basic information for Julia packages.

  #' @usage basic_information()
  #' @return data.table with basic information.

  parse_licence_owner = function(pkgvertest) {
    #' Parse licence and owner.
    #'
    #' @description Parses the licence and ownder if package availble for
    #' supported release. It returns a data.table with NA for the values when no
    #' version for current release.
    #'
    #' @param pkgvertest character. A pkgvertest text
    #' @usage parse_licence_owner(pkgvertest)
    #' @return data.table with licence and owner.
    obj = str_split(string = pkgvertest, pattern = '\n')[[1]]
    if (any(grepl(pattern = 'Julia v0.6', obj))) {
      Licence = str_sub(obj[1], end = -2)
      Owner = str_extract(string = obj[2], pattern = '(?<=Owner: ).*')
      output = data.table(Licence = Licence, Owner = Owner)
    } else {
      output = data.table(Licence = NA, Owner = NA)
    }
    return(output)
  }

  response = read_html('https://pkg.julialang.org/')
  Name = response %>%
    html_nodes('.pkgnamedesc a') %>%
    html_text()
  Description = response %>%
    html_nodes('h4') %>%
    html_text()
  Repositories = response %>%
    html_nodes('.pkgnamedesc a') %>%
    html_attr('href')
  OwnerLicence = response %>%
    html_nodes('.pkgvertest') %>%
    html_text() %>%
    str_trim()
  OwnerLicence = lapply(X = response %>%
                          html_nodes('.pkgvertest') %>%
                          html_text() %>%
                          str_trim(),
                        FUN = parse_licence_owner)
  OwnerLicence = do.call(what = rbind, args = OwnerLicence)
  output = cbind(Name, OwnerLicence, Description, Repositories)
}
basic_information = basic_information()
basic_information = basic_information %>%
  mutate(Package_Status = 'Maintained') %>%
  mutate(Package_Status = ifelse(test = (Owner == 'JuliaArchive') |
                                   str_detect(string = Description,
                                              pattern = '(?i)(deprecated)'),
                                 yes = 'Deprecated',
                                 no = Package_Status))
basic_information = basic_information %>%
  mutate(Tests = sapply(X = Name, FUN = pass),
         SomethingWorks = sapply(X = Name, FUN = something_works),
         Travis = sapply(X = Repositories, FUN = stable_last))

map_lgl(.x = basic_information$Repository[1:2],
        .f = stable_last)

Alrighty = basic_information %>%
  filter((Package_Status %in% 'Maintained') &
           (Tests | SomethingWorks | Travis))
Investigate = basic_information %>%
  filter((Package_Status %in% 'Maintained') &
           !(Tests | SomethingWorks | Travis))

chk = basic_information %>%
  filter(!(Tests | SomethingWorks) & Travis)

table(basic_information$Tests)
table(basic_information$SomethingWorks)
x = vector(mode = 'logical', length = nrow(basic_information))
for (i in i:nrow(basic_information)) {
  print(i)
  x[i] = stable_last(repo = basic_information$Repositories[i])
}

repo = basic_information$Repositories[3]

table(basic_information$Travis)

name = 'Distributions'
response = read_html('https://pkg.julialang.org/detail/NCEI') %>%
  html_nodes(css = 'pre, h4') %>%
  html_text()
arg = response
response = grepl(pattern = 'Tests pass',
                 x = GET(url = str_c('https://pkg.julialang.org/detail/',
                                     name)) %>%
                   content(as = 'text') %>%
                   str_remove_all(pattern = '\n') %>%
                   str_extract(pattern = '(?<=<h4>Julia v0.6</h4>\\s{4}<pre>).*(?=</pre>\\s{8}<h4>)'))

str_extract(string = x, pattern = '(?<=<h4>Julia v0.6</h4>    <pre>).*')
?str_extract
response
html_nodes(css = 'pre, h4') %>%
  html_text(trim = TRUE)
?html_text
which(grepl(pattern = 'Julia v0.6', x = response))[-1]
is_empty(which(grepl(pattern = 'Julia v1', x = response))[-1])

response[4]
response[5]
response[6]
response[7]

html_text(x = 'https://pkg.julialang.org/detail/NCEI')

https://pkg.julialang.org/detail/Iterators

url = chk$Repositories[1]
basic_information = basic_information %>%
  mutate(Dep = sapply(X = Repositories, FUN = re_derect))
re_derect = function(url) {
  response = GET(url = url)
  str_extract(string = response$url,
              pattern = '(?<=github.com/).*') ==
    str_extract(string = url,
                pattern = '(?<=github.com/).*')
}
chk2 = basic_information %>%
  filter(!Dep)


owner_repo = function(url) {
  #' Parses the owner and repository.
  #'
  #' @description Obtains the owner and repository.

  #' @usage owner_repo(url)
  #' @return named vector with owner and repository.
}
basic_information = basic_information %>%
  mutate(Repo = str_extract(string = Repositories,
                            pattern = str_c('(?<=', basic_information$Owner, '/).*$')))

