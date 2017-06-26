library(rvest)
library(stringr)

cran_scrape <- function(link){
  #creating the html link to read
  SFLink <- read_html(link)

  #Get the Title of Cran Packages
  packages <- SFLink %>%
    html_nodes('td a') %>%
    html_text() %>%
    str_trim()

  #Get the description of Cran Packages
  description <- SFLink %>%
    html_nodes('td+ td') %>%
    html_text() %>%
    str_trim()


  v = list('oss_name' = packages, 'description' = description)
  return(data.frame(v, stringsAsFactors = F))
}

Link <- "https://cran.r-project.org/web/packages/available_packages_by_name.html"

all_packages <- cran_scrape(Link)

save(all_packages, file = "~/git/oss/data/oss/original/depsy/all_packages_cran.Rdata")
