# Julia

readr::write_csv(x = crazy4 %>%
                   select(owner, name, repository, status),
                 path = './data/oss/working/Julia/licenses.csv')
readr::write_csv(x = crazy4 %>%
                   select(owner, name, repository, status),
                 path = './data/oss/working/Julia/licenses.csv')


?readr::write_csv
getwd()
list.files('.data')


# Housekeeping
pacman::p_load(docstring, sdalr, DBI, httr, jsonlite, dplyr, purrr, stringr,
               data.table, dtplyr)

Sys.setenv(PATH = str_c(str_remove_all(string = Sys.getenv('PATH'),
                                       pattern = ':~/.gem/ruby/2.5.0/bin'),
                        '~/.gem/ruby/2.5.0/bin', sep = ':'))
github_api_token = c(Authorization = 'token d77961efcd1dc0ae2b9ebb2fe6c9349e1a9c3da0')

# owner_name_repo() # last run with 7abfde6
julia_packages = function() {
  conn = con_db(dbname = 'jbsc',
                pass = get_my_password())
  julia_packages = dbReadTable(conn = conn,
                               name = 'julia_packages') %>%
    data.table()
  on.exit(dbDisconnect(conn = conn))
  return(value = julia_packages)
}
julia_packages = julia_packages()

dependencies = function(name) {
  # name = julia_packages$name[13]
  filename = str_c('./data/oss/original/Julia/METADATA.jl',
                   str_remove(string = name,
                              pattern = '\\.jl$'),
                   'versions',
                   sep = '/')
  latest = list.files(path = filename)
  if (is_empty(x = latest)) {
    output = data.table(name = name,
                        version = NA,
                        julia_min = NA,
                        julia_max = NA,
                        dependency = NA)
  } else {
    latest = max(x = latest)
    dependencies = suppressWarnings(expr = readLines(con = str_c(filename,
                                                                 latest,
                                                                 'requires',
                                                                 sep = '/')))
    julia = str_detect(string = dependencies,
                       pattern = '^julia\\sv?\\d')
    julia_min_max = str_remove(string = dependencies[julia],
                               pattern = '^julia\\s') %>%
      str_split(pattern = '\\s', n = 2) %>%
      unlist()
    if (is_empty(x = julia_min_max)) {
      julia_min = NA
      julia_max = NA
    } else {
      julia_min = julia_min_max[1L] %>%
        str_remove(pattern = '^v')
      if (length(julia_min_max) == 1L) {
        julia_max = ifelse(test = str_detect(string = julia_min,
                                             pattern = '^0.7'),
                           yes = '0.7',
                           no = '0.6')
      } else {
        julia_max = julia_min_max[2L] %>%
          str_remove(pattern = '^v')
      }
    }
    pkgs = dependencies[-!julia] %>%
      str_remove(pattern = '(?<=\\s)\\d.*') %>%
      str_trim()
    pkgs = ifelse(test = is_empty(x = pkgs),
                  yes = NA,
                  no = pkgs)
    output = data.table(name = name,
                        version = latest,
                        julia_min = julia_min,
                        julia_max = julia_max,
                        dependency = pkgs)
  }
  return(value = output)
}

dependencies = map_df(.x = julia_packages$name,
                      .f = dependencies)
get_pkg_eval = function(name) {
  response = str_c('https://pkg.julialang.org/detail/',
                   str_remove(string = name,
                              pattern = '\\.jl$'),
                   '.html') %>%
    GET()
  if (status_code(x = response) == 200L) {
    output = response %>%
      content(as = 'text', encoding = 'UTF-8') %>%
      str_replace_all(pattern = '\n', '\\s') %>%
      str_remove(pattern = '^.*(?=<h3>Version and Status History</h3>)') %>%
      str_extract(pattern = '(?<=<h4>Julia v0.6</h4>).*(?=<h4>Julia v0.7</h4>)')
    if (is.na(x = output)) {
      output = 'UNMAINTAINED'
    } else if (str_detect(string = output,
                          pattern = 'Tests pass')) {
      output = 'OK'
    } else if (str_detect(string = output,
                          pattern = 'No tests detected')) {
      output = 'DEVELOPMENT'
    } else {
      output = NA
    }
  } else {
    output = NA
  }
  return(value = output)
}

description = description %>%
  mutate(deprecated = str_detect(string = description,
                                 pattern = '(?i)(deprecated)'))
description2 = description %>%
  select(repository, deprecated) %>%
  merge(y = select(julia_packages, repository, name)) %>%
  select(-repository) %>%
  data.table()

description = do.call(what = rbind,
                      args = crazy)
pkg_eval = data.table(name = julia_packages$name) %>%
  mutate(tests_passed = map_chr(.x = name,
                                .f = get_pkg_eval))
pkg_status = julia_packages %>%
  select(owner, name, repository) %>%
  mutate(status = ifelse(test = owner == 'JuliaArchive',
                         yes = 'DEPRECATED',
                         no = NA)) %>%
  merge(y = description2) %>%
  mutate(status = ifelse(test = deprecated,
                         yes = 'DEPRECATED',
                         no = status)) %>%
  select(-c(owner, deprecated)) %>%
  merge(y = select(dependencies, name, julia_max) %>%
          unique()) %>%
  mutate(status = ifelse(test = ((!str_detect(string = julia_max,
                                             pattern = '^0\\.[6|7]')) &
                                   !(status %in% 'DEPRECATED')),
                         yes = 'UNMAINTAINED',
                         no = status)) %>%
  select(-julia_max) %>%
  data.table() %>%
  merge(y = pkg_eval) %>%
  mutate(status = ifelse(test = (!is.na(tests_passed) & is.na(x = status)),
         yes = tests_passed,
         no = status)) %>%
  select(-tests_passed) %>%
  data.table()
badfellas = pkg_status %>%
  filter(is.na(x = status)) %>%
  mutate(status_2 = perfect_travis)

crazy2 = pkg_status %>%
  merge(y = select(badfellas, name, status_2), all.x = TRUE) %>%
  mutate(status = ifelse(test = is.na(status),
                         yes = status_2,
                         no = status)) %>%
  select(name, status) %>%
  data.table()
actual_repositories = function(repository) {
  output = repository %>%
    GET() %>%
    getElement(name = 'url')
  return(value = output)
  }

actual_repos = map_chr(.x = julia_packages$repository,
                       .f = actual_repositories)
julia_packages = julia_packages %>%
  mutate(repository = actual_repos,
         owner = str_extract(string = repository,
                             pattern = '(?<=\\.\\w{3}/).*(?=/)'))
crazy3 = crazy2 %>%
  merge(y = select(julia_packages, owner, name, repo, repository)) %>%
  mutate(status = ifelse(test = str_detect(string = owner,
                                           pattern = '^JuliaArchive$'),
                         yes = 'DEPRECATED',
                         no = status))

table(crazy3$status)



manually = vector(mode = 'list')
manually$

slugs = str_extract(string = badfellas$repository,
                    pattern = '(?<=com/).*')

check_travis = function(slug) {
  branches = GET(url = str_c('https://api.travis-ci.org/repos/',
                             slug,
                             '/branches'),
                 add_headers(c(Accept = 'application/json',
                               Authorization = 'token DRt1TjjDmPG4wX8bq0YqVg'))) %>%
    content(as = 'text', encoding = 'UTF-8') %>%
    fromJSON()
  if (is_empty(x = branches[[1L]])) {
    return(value = NA)
  }
  tested_6 = map_lgl(.x = branches$branches$config$julia,
                     .f = function(branch) {
                       any(str_detect(string = branch,
                                      pattern = '\\.6'))
                     })
  tested_release = map_lgl(.x = branches$branches$config$julia,
                           .f = function(branch) {
                             any(str_detect(string = branch,
                                            pattern = 'release'))
                             # Using date of Julia 0.6.0 release
                           }) & branches$branches$started_at >= as.Date(x = '2017-06-19')
  tested = tested_6 | tested_release
  passed = str_detect(string = branches$branches$state,
                      pattern = 'passed')
  candidates = branches$commits$branch %>%
    subset(subset = tested & passed)
  if (any(str_detect(string = candidates,
                     pattern = '^v\\d\\.\\d\\.\\d$'))) {
    output = 'OK'
  } else if (!is_empty(x = candidates)) {
    output = 'DEVELOPMENT'
  } else {
    output = 'Undetermined'
  }
  return(value = output)
}

travis_ci = crazy3 %>%
  filter(!(status %in% c('OK','DEPRECATED','UNMAINTAINED','DEVELOPMENT')))

deprecated_in_readme = function(repository) {
  # repository = 'https://github.com/dcjones/Zlib.jl'
  output = str_c('https://raw.githubusercontent.com/',
                 str_extract(string = repository,
                             pattern = '(?<=\\.\\w{3}/).*'),
                 '/master/README.md') %>%
    GET() %>%
    content(as = 'text',
            encoding = 'UTF-8') %>%
    str_detect(pattern = '(?i)deprecated')
  return(value = output)
}
deprecated_in_readme = map_lgl(.x = travis_ci$repository,
                               .f = deprecated_in_readme)
travis_ci$repository[deprecated_in_readme]

travis_ci = travis_ci %>%
  mutate(status = ifelse(test = repository %in% repository[deprecated_in_readme],
         yes = 'DEPRECATED',
         no = status))

yolo = travis_ci %>%
  mutate(status_2 = status %in% 'DEPRECATED')

conn = con_db(dbname = 'jbsc',
              pass = get_my_password())
dbWriteTable(conn = conn,
             name = 'dependencies',
             value = dependencies,
             row.names = FALSE,
             overwrite = TRUE)
dbDisconnect(conn = conn)

for_review = julia_packages2 %>%
  data.table(key = c('owner','name')) %>%
  setcolorder(neworder = c('owner','name','repo',
                           'repository','remote_platform','description'))

julia_packages2 = julia_packages %>%
  merge(y = select(description, repository, description),
        by = 'repository') %>%
  merge(y = select(crazy4, name, status),
        by = 'name')



setdiff(julia_packages$name, julia_packages2$name)

dbWriteTable(conn = conn,
             name = 'julia_packages',
             value = dependencies,
             row.names = FALSE,
             overwrite = TRUE)
dbDisconnect(conn = conn)




crazy4 = crazy3 %>%
  merge(y = select(yolo, repository, status_2),
        all.x = TRUE,
        by = 'repository') %>%
  mutate(status = if_else(condition = status_2,
                          true = 'DEPRECATED',
                          false = status,
                          missing = status)) %>%
  select(-status_2) %>%
  data.table() %>%
  mutate(status = ifelse(test = (is.na(x = status) | (status %in% 'UNDETERMINED')),
                         yes = 'UNMAINTAINED',
                         no = status))

mutate(travis = map_lgl(.x = slugs,
                          .f = check_travis))

travis_ci = vector(mode = 'list', length = length(x = slugs))
table(crazy3$status)


for (i in which(perfect_travis == '')) {
  print(i)
  perfect_travis[i] = check_travis(slug = slugs[i])
  Sys.sleep(time = 1L)
}

perfect_travis = map_chr(test = slugs[!better_travis],
                        yes = 'OK',
                        no = '')



better_travis = unlist(travis_ci)
table(better_travis)


table(better_travis)

pkg_eval(name = 'ZVSimulator.jl')
pkg_eval(name = 'NCEI.jl')
pkg_eval(name = 'DataFrames.jl')
pkg_eval(name = 'SecureSessions.jl')

currently_working(name = pkg_status$name)


  str_extract(string = response %>%
                str_replace_all(pattern = '\n', '\\s'),
              pattern = '(?<=<h3>Version and Status History</h3>).*')

  output = str_extract(string = response %>%
                         str_replace_all(pattern = '\n', '\\s') %>%
                         str_remove(pattern = '^.*(?=<h3>Version and Status History</h3>)') %>%
                         str_extract(pattern = '(?<=<h4>Julia v0.6</h4>).*(?=<h4>Julia v0.7</h4>)'),
                       pattern = 'Tests pass')
  output = ifelse(test = is.na(x = output),
                  yes = FALSE,
                  no = output)
  status_code(x = response)
  response %>%
    rvest::html_nodes(css = 'h4 , pre')
}


for (i in 1:length(julia_packages$name)) {
  print(i)
  pkg_eval(name = julia_packages$name[i])
}

dependencies = map_df(.x = julia_packages$name,
                      .f = dependencies)

dependencies(name = julia_packages$name[1])

JuliaComputing/ArrayFire.jl/v0.1.0/REQUIRE')
  /repos/:owner/:repo/releases
}
