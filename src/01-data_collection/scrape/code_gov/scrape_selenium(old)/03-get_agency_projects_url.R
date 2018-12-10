library(RSelenium)
library(rvest)

agencies <- read.csv('data/oss/working/code_gov/agency_urls.csv', stringsAsFactors = FALSE)

urls <- agencies$url
names <- stringr::str_to_lower(agencies$short_name)

testthat::expect_equal(length(urls), length(names))

rerun <- c()

agency_full_name <- data.frame(short_name = character(0),
                               long_name = character(0))
agency_full_name

agency_project_url_data <- data.frame(agency = character(0),
                                      agency_url = character(0),
                                      project_name = character(0),
                                      project_url = character(0))
agency_project_url_data

agency_project_count_data <- data.frame(agency = character(0),
                                        num_projects = numeric(0))
agency_project_count_data

# loop through each agency url
# i <- 2
for (i in 1:length(urls)) {
  print('Create new Selenium remote driver')
  remDr <- remoteDriver(remoteServerAddr = "selenium_chrome_chend"
                        , port = 4440
                        , browserName = "chrome"
  )
  sink(tempfile())
  remDr$open()
  sink()
  # remDr$getStatus()
  print(remDr$getStatus()$message)

  print(i)
  agency_url <- urls[i]
  agency <- names[i]

  print(agency)
  print(agency_url)

  # go to each agency url
  remDr$navigate(agency_url)
  print(remDr$getCurrentUrl()[[1]])

  Sys.sleep(5)

  # find all the projects for the agency
  project_li <- remDr$findElements(using = 'class name', 'repo')

  num_projects <- length(project_li)
  print(sprintf('Num Projects: %s', num_projects))

  if (num_projects == 0) {
    rerun <- c(rerun, i)
    remDr$closeall()
    sleep_next_agency_project <- runif(1) * 10
    print(sprintf('Sleeping (next agency): %s', sleep_next_agency_project))
    Sys.sleep(sleep_next_agency_project)
    next
  }

  agency_project_count_data <- rbind(agency_project_count_data,
                                     data.frame(agency = agency, num_projects = num_projects))

  # loop through each project
  # proj_i <- 3
  for (proj_i in 1:num_projects) {
    print(proj_i)
    webEl <- project_li[[proj_i]]

    try({
      found_a <- webEl$findChildElement(using = "tag name", 'a')
      project_url <- found_a$getElementAttribute('href')[[1]]

      found_h3 <- webEl$findChildElement(using = "tag name", 'h3')
      project_name <- found_h3$getElementText()[[1]]

      print(project_name)
      print(project_url)

      proj_url_df <- data.frame(agency = agency, agency_url = agency_url,
                                project_name = project_name, project_url = project_url)
      agency_project_url_data <- rbind(agency_project_url_data, proj_url_df)
      print(agency_project_url_data)
    })

    sleep_next_agency_project <- runif(1) * 10
    print(sprintf('Sleeping (project url): %s', sleep_next_agency_project))
    Sys.sleep(sleep_next_agency_project)
  }
  sleep_time <- runif(1) * 10
  print(sprintf('Sleeping: %s', sleep_time))
  Sys.sleep(sleep_time)
  remDr$closeall()

  print('----------')
  print(agency_project_url_data)
  # break
}

print(agency_project_url_data)
print(agency_project_count_data)
print(rerun)

write.csv(agency_project_count_data, sprintf('data/oss/original/code_gov/agencies/agency_project_count-%s.csv', Sys.time()))
write.csv(agency_project_url_data, sprintf('data/oss/original/code_gov/agencies/agency_project_url-%s.csv', Sys.time()))
