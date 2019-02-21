# functions
# this is the shared functions file

# functions
#parse author email
#x is a vec, list, or df containing author information
#returns a df with 1st column as author names, 2nd column as emails
#multiple emails for 1 author results in multiple rows
parse_author_email = function(x) {
  result = data.frame()
  if (is(x, "character")) {
    author_names = str_extract(string = x,
                               pattern = '^.*?(?=\\s\\<|\\(|$)')
    if (!grepl("[[:alpha:]]", author_names[1]) & !grepl("[[:digit:]]", author_names[1])) {
      author_names = NA
    }
    author_emails = str_extract(string = x,
                                pattern = '(?<=\\<).*?(?=\\>)')
    
    result = data.frame(author = author_names,
                        email = author_emails)
  } else if (is(x, "list")) {
    result = data.frame(author = x[[1]],
                        email = ifelse(length(x) >= 2, x[[2]], NA))
  } else if (is(x, "data.frame")) {
    result = x[, 1:2]
    colnames(result) <-  c("author", "email")
  }
  return(value = result)
}

#parse and save author's/authors' name and email for a JS package
#pkg_name is a package name
#json_file is a json file obtained from github,
#containing the package's info, loaded as a df
#return a df with 1st column as package name, 2nd column as author names
# and 3rd column as author emails
parse_author_info = function (pkg_name, json_file) {
  #if the json file has no author info
  if (is.null(json_file$author) && is.null(json_file$authors)) {
    result = data.frame(name = pkg_name,
                        author = NA,
                        email = NA)
  } 
  #otherwise
  else {
    if (!is.null(json_file$author)) {
      feed = json_file$author
    } else if (!is.null(json_file$authors)) {
      feed = json_file$authors
    }
    
    result = parse_author_email(feed) %>%
      mutate(name = pkg_name)
  }
  
  return(value = result)
}


#parse and save author's/authors' name and email for a JS package
#unlike parse_author_info, it does not require manually loading the json file
#filename is a json file's name
#returns a df with col 1 as package name, col 2 as authors, col 3 as author emails
load_parse_author_info = function (filename) {
  
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN/CDN_json/).*') %>%
    str_remove(".json$")
  
  #load file
  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()
  
  #try to gather author and author email info and put them in the returning df
  if (is.null(json_file$author) & is.null(json_file$authors)) {
    result = data.frame(name = pkg_name,
                        author = NA,
                        email = NA)
  } else {
    if (!is.null(json_file$author)) {
      feed = json_file$author
    } else if (!is.null(json_file$authors)) {
      feed = json_file$authors
    }
    
    result = parse_author_email(feed) %>%
      mutate(name = pkg_name)
  }
  
  return(value = result)
}

#parse and save the license info
#pkg_name is a package name
#json_file is a json file obtained from github,
#containing the package's info
#return a df with 1st column as package name, 2nd column as licenses
parse_license_info = function (pkg_name, json_file) {
  if(!is.null(json_file$licenses)) {
    if (is(json_file$licenses, "data.frame")) {
      license = json_file$licenses[[1]]
    } else if (is(json_file$licenses, "list")) {
      license = json_file$licenses$type
    } else {
      license = json_file$licenses
    }
  } else if (!is.null(json_file$license)) {
    if (is(json_file$license, "data.frame")) {
      license = json_file$license[[1]]
    } else if (is(json_file$license, "list")) {
      license = json_file$license$type
    } else {
      license = json_file$license
    }
  } else {
    license = NA
  }
  
  result = data.frame(license = license) %>%
    mutate(name = pkg_name)
  
  return(value = result)
}


#parse and save the version and dependency info
#pkg_name is a package name
#json_file is a json file obtained from github,
#containing the package's info
#return a df with 1st column as package name, 2nd column as version,
#3rd column as dependency
parse_denpendency_info = function (pkg_name, json_file) {
  version = json_file$version
  dependency = json_file$devDependencies %>% names
  
  if (is.null(json_file$version)) {
    version = NA
  }
  
  if (is.null(json_file$devDependencies)) {
    dependency = NA
  }
  
  result = data.frame(dependency = json_file$devDependencies %>% names) %>%
    mutate(name = pkg_name) %>%
    mutate(version = version)
  
  return(value = result)
}

#parse the version and dependency info of a package
#unlike parse_denpendency_info, it does not require preloading json file
#parsing is also slightly different
#filename is a json file's name
#returns a df with col 1 as package name, col 2 as version, col 3 as dependency
load_parse_denpendency_info = function (filename) {
  #get pkg name
  pkg_name = str_extract(string = filename,
                         pattern = '(?<=CDN_json/).*') %>%
    str_remove(".json$")
  
  #load file
  json_file = suppressWarnings(readLines(con = filename)) %>%
    str_c(collapse = ' ') %>%
    fromJSON()
  
  #extract version and dependency
  version = json_file$version
  dependency = json_file$devDependencies %>% names
  if (is.null(version)) {
    version = NA
  }
  
  tryCatch({
    df <- as.data.frame(dependency)
    df$version <- version
    df$name <- pkg_name
    return(df)
  }, error = function(e){
    return(data.frame('pkg_name' = pkg_name, 'version' = version, "dependency" = NA))
  })
}


#trim repo urls so they fit github API
#repo is a string of repo url
#returns trimmed versim of the repo
fix_url = function(repo) {
  fixed = str_replace(repo, "^.*(?<=github.com.)", "https://github.com/") %>%
    str_remove("(/|\\.git)$")
  return(fixed)
}
