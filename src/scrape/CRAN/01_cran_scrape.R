#script for scraping CRAN
library(rvest)
library(stringr)

url <- "https://cran.r-project.org/web/packages/available_packages_by_date.html"
url <- read_html(url)

cran_scrape <- function(link){
  #read in link to package
  append_link <- paste0("https://cran.r-project.org/web/packages", link)
  CRANLink <- read_html(append_link)
}
