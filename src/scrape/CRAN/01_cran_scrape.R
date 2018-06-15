#script for scraping CRAN
library(rvest)
library(stringr)
library(magrittr)

#function for each package page
page_scrape <- function(link){
  #read in link to package
  CRANLink <- read_html(link)

  #get the title of the package
  long_title <- CRANLink %>%
    html_node('h2') %>%
    html_text() %>%
    str_trim()

  #parse abbreviated title
  ptitle <- str_extract(long_title,"(?<=\\: ).*")
  #parse the full title
  abrv <- str_extract(long_title,".*(?=\\:)")


  tabs <- CRANLink %>%
    html_node('table') %>%
    html_table()
  tabs <- t(tabs$X2)
  tabs

  frame <- cbind(abrv,ptitle,tabs)
  frame <- list(frame)

  return(frame)
}

#from CRAN get all names of packages
url <- "https://cran.r-project.org/web/packages/"
link_gen <- "https://cran.r-project.org/web/packages/available_packages_by_name.html"
link_gen <- read_html(link_gen)

link_list <- link_gen %>%
  html_nodes('td a') %>%
  html_text() %>%
  str_trim()

#Append CRAN package link to front of all names to get link to all packages
#now we have a list of all the links to CRAN projects
master_list <- paste0(url, link_list)

#load parallel library to make faster
library(parallel)
library(doParallel)
#initialize cluster
par <- makeCluster(12)
registerDoParallel(par)
#load libraries and local var/function on each process
clusterExport(par,c("page_scrape", "master_list"))
clusterEvalQ(par,library(rvest))
clusterEvalQ(par,library(stringr))

#iterate over the list and scrape each one
master_frame <- parLapply(cl = par, X = master_list, fun = function(x){page_scrape(x)})

#close the cluster
stopCluster(par)
registerDoSEQ()


#ONLY USE THIS to write out to file
#saveRDS(master_frame, file= "data/oss/original/CRAN_2018/master_frame.RDS")
