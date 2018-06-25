#making two new tables; load packages
library(rvest)
library(xml2)
library(stringr)
library(magrittr)
#from CRAN get all names of packages
url <- "https://cran.r-project.org/web/packages/"
link_gen <- "https://cran.r-project.org/web/packages/available_packages_by_name.html"
link_gen <- read_html(link_gen)

link_list <- link_gen %>%
  html_nodes('td a') %>%
  html_text() %>%
  str_trim()

#function for each package page - get CRAN checks
page_scrape <- function(link){
  #read in link to package
  link = 'https://cran.r-project.org/web/packages/ggplot2'
  CRANLink <- read_html(link)

  #get the title of the package
  short_title <- CRANLink %>%
    html_node('h2') %>%
    html_text() %>%
    str_trim() %>%
    str_replace_all(pattern = '\n', replacement = ' ') %>%
    str_extract(".*(?=\\:)")#cut out newlines

  check <- CRANLink %>%
    html_nodes('p+ table tr') %>%
    xml_children() %>%
    xml_children() %>%
    html_attr('href')

  check <- check[length(check)] #seeing a pattern that checks are always last
  check_link <- paste0(link,'/',check)

}

############# need to get links to citations and links to tests
