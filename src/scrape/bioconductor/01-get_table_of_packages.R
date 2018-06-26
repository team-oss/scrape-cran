# Since the main bioconductor package release page has all the bioc packages
# we pull the entire table on the page

library(rvest)
library(stringr)

page <- read_html('https://www.bioconductor.org/packages/release/bioc/')

release_no <- page %>%
  html_nodes('#PageContent p') %>%
  html_text() %>%
  str_trim() %>%
  readr::parse_number()

release_no

write_html(page, sprintf('./data/oss/original/bioconductor/%s/packages_v%s.html', release_no, release_no))
