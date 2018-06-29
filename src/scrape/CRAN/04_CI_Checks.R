#making two new tables; load packages
library(rvest)
library(xml2)
library(stringr)
library(magrittr)
library(data.table)
#from CRAN get all names of packages
url <- "https://cran.r-project.org/web/packages/"
link_gen <- "https://cran.r-project.org/web/packages/available_packages_by_name.html"
link_gen <- read_html(link_gen)

link_list <- link_gen %>%
  html_nodes('td a') %>%
  html_text() %>%
  str_trim()
master_list <- paste0(url, link_list)
#function for each package page - get CRAN checks
page_scrape <- function(link){
  #read in link to package
  CRANLink <- read_html(link)

  #get the shortened title of the package
  short_title <- CRANLink %>%
    html_node('h2') %>%
    html_text() %>%
    str_trim() %>%
    str_replace_all(pattern = '\n', replacement = ' ') %>%
    str_extract(".*(?=\\:)")#cut out newlines

  #get the link to the CI check table
  check <- CRANLink %>%
    html_nodes('p+ table tr') %>%
    xml_children() %>%
    xml_children() %>%
    html_attr('href')

  #get the correct HREF, then paste to base link
  check <- check[length(check)] #seeing a pattern that checks are always last
  check_link <- paste0(link,'/',check)

  #start scraping again with new link
  check_link <- read_html(check_link)

  tabs <- check_link %>%
    html_node('table') %>%
    html_table()

  #I only want release versions / flavors
  tabs <- data.table(tabs)
  tabs <- tabs[str_detect(Flavor,'release') == T]

  #drop irrelevant columns
  tabs <- tabs[,c(1,2,6)]
  tabs[,'Package_Name'] <- rep(short_title,nrow(tabs))

  return(tabs)
}

############# parallel stuff now
#load parallel library to make faster
library(parallel)
library(doParallel)
#initialize cluster
par <- makeCluster(10)
registerDoParallel(par)
#load libraries and local var/function on each process
clusterExport(par,c("page_scrape", "master_list"))
clusterEvalQ(par,library(rvest))
clusterEvalQ(par,library(stringr))
clusterEvalQ(par,library(data.table))

#iterate over the list and scrape each one
master_frame <- parLapply(cl = par, X = master_list, fun = function(x){page_scrape(x)})

#close the cluster
stopCluster(par)
registerDoSEQ()


#ONLY USE THIS to write out to file
#saveRDS(master_frame, file= "data/oss/original/CRAN_2018/CI_checks.RDS")
