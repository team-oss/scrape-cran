library(RSelenium)
library(xml2)

remDr <- remoteDriver(remoteServerAddr = "selenium_chrome"
                      , port = 4444
                      , browserName = "chrome"
)

remDr$open()
remDr$getStatus()

remDr$navigate("https://code.gov/#/explore-code/")

source_char <- remDr$getPageSource()[[1]]
source_char

saveRDS(source_char, file = 'data/oss/original/code_gov/01-explore_code.RDS')

source <- xml2::read_html(source_char)
source

xml2::write_html(source, 'data/oss/original/code_gov/01-explore_code.html')
