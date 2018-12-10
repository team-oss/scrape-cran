# used the pulled html table to get package url pages
#
library(rvest)
library(dplyr)

page <- read_html('./data/oss/original/bioconductor/3.7/packages_v3.7.html')

tbl <- page %>%
  html_nodes('table') %>%
  html_table() %>%
  .[[1]]

tbl

base_pkg_url <- 'https://www.bioconductor.org/packages/release/bioc/'

page_urls <- page %>%
  html_nodes('table') %>%
  html_nodes('a') %>%
  html_attr('href') %>%
  paste0(base_pkg_url, .)

tbl <- tbl %>%
  mutate(url = page_urls)

write.csv(tbl, './data/oss/original/bioconductor/3.7/packages_v3.7.csv', row.names = FALSE)
