library(dplyr)
library(RSelenium)

count_data <- read.csv('data/oss/original/code_gov/agencies/agency_project_count-2018-03-29 06:22:24.csv', stringsAsFactors = FALSE)
url_data <- read.csv('data/oss/original/code_gov/agencies/agency_project_url-2018-03-29 06:24:07.csv', stringsAsFactors = FALSE)

url_agency_count <- url_data %>%
  group_by(agency) %>%
  summarize(n = n())

joined_counts <- url_agency_count %>%
  left_join(count_data, by = c('agency', 'agency'))

joined_counts[!joined_counts$n == joined_counts$num_projects, ]


url_data$project_url

button_urls <- c()

for (url in url_data$project_url) {
  print('Create new Selenium remote driver')
  remDr <- remoteDriver(remoteServerAddr = "selenium_chrome"
                        , port = 4444
                        , browserName = "chrome"
  )
  sink(tempfile())
  remDr$open()
  sink()
  print(remDr$getStatus()$message)

  print(url)

  tryCatch({
    remDr$navigate(url)
    Sys.sleep(5)
    print(remDr$getCurrentUrl()[[1]])

    button <- remDr$findElement(using = 'class name', 'button')
    button$clickElement()
    button_url <- button$getCurrentUrl()[[1]]
    button_urls <- c(button_urls, button_url)
  }, error = function(e) {
    button_urls <- c(button_urls, NA)
  }, finally = {
    print('-----')
    print(button_urls)

    sleep_time <- runif(1) * 10
    print(sprintf('Sleeping (end of url parse): %s', sleep_time))
    Sys.sleep(sleep_time)
    remDr$closeall()
  })
}
