#this will get lines of code from packages on CRAN that are not also on github
library(stringr)
library(dplyr)
library(rvest)

get_source_table <- function(link){
  CRANLink <- read_html(link)
  tabs <- CRANLink %>%
    html_nodes('table')

  sources <- tabs[2] #we get the second html table on the page, which is the source info
  pack_src <- sources %>%
    html_nodes('a')
  pack_src <- pack_src[str_detect(pack_src,"tar.gz")] %>%
    html_attr('href')
  pack_src <- str_replace(pack_src,"(\\../../..)","https://cran.r-project.org")


  #get the title of the package
  long_title <- CRANLink %>%
    html_node('h2') %>%
    html_text() %>%
    str_trim() %>%
    str_replace_all(pattern = '\n', replacement = ' ') #cut out newlines

  #parse abbreviated title
  ptitle <- str_extract(long_title,"(?<=\\: ).*")
  #parse the full title
  abrv <- str_extract(long_title,".*(?=\\:)")

  frame <- cbind(abrv,ptitle,pack_src)
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


library(parallel)
library(doParallel)
#initialize cluster
par <- makeCluster(10)
registerDoParallel(par)
#load libraries and local var/function on each process
clusterExport(par,c("get_source_table", "master_list"))
clusterEvalQ(par,library(rvest))
clusterEvalQ(par,library(stringr))

#iterate over the list and scrape each one
master_frame <- do.call("rbind",parLapply(cl = par, X = master_list,fun = function(x){get_source_table(x)}))

#close the cluster
stopCluster(par)
registerDoSEQ()

#clean up frame
master_frame <- as.data.frame(master_frame)

#save out
#saveRDS(master_frame, file = './data/oss/original/CRAN_2018/cran_src.RDS')
