# functions
parse_author_email = function(x) {
  result = data.frame()
  if (is(x, "character")) {
    author_names = str_extract(string = x,
                               pattern = '^.*?(?=\\s\\<|\\(|$)')
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

#parse and save the author's/authors' name and email
parse_author_info = function (pkg_name, json_file) {
  if (is.null(json_file$author) && is.null(json_file$authors)) {
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
parse_license_info = function (pkg_name, json_file) {
  if(!is.null(json_file$licenses)) {
    if (is(json_file$licenses, "data.frame")) {
      #print(json_file$licenses)
      license = json_file$licenses[[1]]
    } else if (is(json_file$licenses, "list")) {
      license = json_file$licenses$type
    } else {
      license = json_file$licenses
    }
    # result = data.frame(license = license) %>%
    #   mutate(name = output$name)
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
    # result = data.frame(name = output$name,
    #                     license = NA)
  }

  result = data.frame(license = license) %>%
    mutate(name = pkg_name)

  return(value = result)
}


#parse and save the version and dependency info

#######(MIT)
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
