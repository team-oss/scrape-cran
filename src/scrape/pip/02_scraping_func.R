scrape_func <- function(base_url, dev_stat, page)
{
  # base_url <- "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+5+-+Production%2FStable&c=License+%3A%3A+OSI+Approved&o=&q=&page=1"
  # dev_stat <- "Production/Stable"
  # page <- 1
  pip_df <- setNames(data.frame(matrix(ncol = 10, nrow = 1)),
                     c("name", "description", "license", "author",
                     "maintainer(s)", "repository", "homepage", "py3", "development_status", "dependencies"))
  position <- 1

  base_site_html <- read_html(base_url)

  names <- base_site_html %>% html_nodes('.package-snippet__title a') %>% html_text()

  for (i in 1:length(names))
  {
    # i = 1
    Sys.sleep(2)

    proj_site <- paste("https://pypi.org/project/", names[i], sep = "")
    proj_site_html <- read_html(proj_site)

    descr <- proj_site_html %>% html_nodes('.package-description__summary') %>% html_text()

    author <- proj_site_html %>% html_nodes('strong+ a') %>% html_text()

    maint <- proj_site_html %>% html_nodes('.sidebar-section__user-gravatar-text') %>% html_text()
    maint2 = maint[1]
    for (j in 1:(length(maint)/2))
    {
      maint2[j] <- trimws(maint[j])
    }
    maintainers <- gsub("'","",paste(shQuote(maint2, type="sh"), collapse=", "))

    lib_site <- paste("https://libraries.io/pypi/", names[i], sep = "")
    license <- NA
    homepage <- NA
    repo <- NA
    if (url.exists(lib_site)) {
      lib_site_html <- read_html(lib_site)
      repo_dta <- lib_site_html %>% html_nodes('.col-md-8') %>% html_text()
      lcns <- str_detect(repo_dta, pattern = 'License')[1]
      hmpg <- str_detect(repo_dta, pattern = 'Homepage')[1]
      rep <- str_detect(repo_dta, pattern = 'Repository')[1]

      if(hmpg) {
        homepage <- lib_site_html %>% html_nodes('span:nth-child(1) a') %>% html_attr('href')
      }
      if(rep){
        repo <- lib_site_html %>% html_nodes('span:nth-child(2) a') %>% html_attr('href')
      }
      if(lcns){
        license <- lib_site_html %>% html_nodes('.col-md-8 dd~ dd a') %>% html_text()
      }

    } else {
      license <- proj_site_html %>% html_nodes('.sidebar-section:nth-child(4) .sidebar-section__title+ p') %>% html_text()
    }

    dta <- proj_site %>% GET() %>% content(as = 'text', encoding = 'UTF-8')
    py3 <- str_detect(dta, pattern = 'Python :: 3')

    setup_url <- paste("https://raw.githubusercontent.com/", maintainers[i], "/", names[i], "/master/setup.py", sep = "")
    dependencies <- NA
    if (url.exists(setup_url)){
      download.file(setup_url, destfile = paste("~/oss/data/oss/working/pypi/", i, names[i], ".txt", sep = ""))
      str_file <- readLines(con = str_c('~/oss/data/oss/working/pypi/', i, names[i], '.txt'))
      start <- str_detect(str_file, pattern = 'install_requires') %>%
        which() %>%
        getElement(name = 1) + 1
      end <- str_detect(str_file[start[1]:length(str_file)], pattern = ']') %>%
        which() %>%
        getElement(name = 1) - 1
      deps <- str_extract(str_file[start:end], pattern = '\\w+(-\\w+)*' )
      dependencies <- gsub("'","",paste(shQuote(deps, type="sh"), collapse=", "))
    }


    pip_df[position, 1] <- names[i]
    pip_df[position, 2] <- descr[1]
    if (length(license) == 0){
      license <- proj_site_html %>% html_nodes('.sidebar-section:nth-child(4) .sidebar-section__title+ p') %>% html_text()
    }
    pip_df[position, 3] <- license[1]
    pip_df[position, 4] <- author[1]
    pip_df[position, 5] <- maintainers
    pip_df[position, 6] <- repo
    pip_df[position, 7] <- homepage
    pip_df[position, 8] <- py3
    pip_df[position, 9] <- dev_stat
    pip_df[position, 10] <- dependencies

    position <- position + 1

    print(paste(dev_stat, page, i, sep = " "))
  }
  return(pip_df)
}
