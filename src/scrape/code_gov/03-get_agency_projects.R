library(RSelenium)
library(rvest)

remDr <- remoteDriver(remoteServerAddr = "selenium_chrome"
                      , port = 4444
                      , browserName = "chrome"
)

remDr$open()
remDr$getStatus()

agencies <- read.csv('data/oss/working/code_gov/agency_urls.csv', stringsAsFactors = FALSE)

urls <- agencies$url
names <- stringr::str_to_lower(agencies$short_name)

testthat::expect_equal(length(urls), length(names))

rerun <- c()

for (i in 1:length(urls)) {
  print(i)
  u <- urls[i]
  n <- names[i]
  fname_html <- sprintf('data/oss/original/code_gov/agencies/%02d-%s.html', i, n)
  fname_rds <- sprintf('data/oss/original/code_gov/agencies/%02d-%s.RDS', i, n)

  print(u)
  print(n)
  print(fname_html)
  print(fname_rds)

  remDr$navigate(url)

  source_char <- remDr$getPageSource()[[1]]
  source_char

  source <- xml2::read_html(source_char)
  source

  projects <- html_nodes(source, '.repo-name')
  print(projects)


  if (length(projects) == 0) {
    rerun <- c(i, rerun)
  }

  saveRDS(source_char, file = fname_rds)
  xml2::write_html(source, fname_html)

  sleep_time <- runif(1) * 20
  print(sprintf('Sleeping: %s', sleep_time))
  Sys.sleep(sleep_time)
  # break
}

print(rerun)

# source_char <- remDr$getPageSource()[[1]]
# source_char
#
# source <- xml2::read_html(source_char)
# source
#
# projects <- html_nodes(source, '.repo-name')
# projects
