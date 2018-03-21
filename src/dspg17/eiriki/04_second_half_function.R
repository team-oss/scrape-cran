#WE DID NOT END UP USING THIS CODE, we used 05_new_SF_project_titles

#this is the second half of web scraping for sourceforge: store the data from the project links we have collected
#We will make a master_list by combining all of the files in the above directory, as rows in a list.
library(RCurl)
library(XML)
library(stringr)
library(rvest)
source(file = "~/git/lab/oss/src/eiriki/01_web_scrape.R")
source(file = "~/git/lab/oss/src/eiriki/03_web_scrape_enterprise.R")
library(tictoc)

tic()
fs <- list.files('~/git/lab/oss/data/oss/original/sourceforge/master_list', full.names = TRUE, pattern = '*.RData')

load_stuff <- function(file_name) {
  load(file_name)
  return(data.frame(new_dat, stringsAsFactors = F))
}

fl <- lapply(X = fs, FUN = load_stuff)

master_list_2 <- data.table::rbindlist(fl)
save(master_list_2, file = '~/git/lab/oss/data/oss/original/sourceforge/master_list_2/master_list_2.RData')
toc()

#apply the function to the master list and store in a data frame
#New_SF <- data.frame()
#for(i in 1:nrow(master_list_2)){
  #new_data <- sf_scrape(master_list_2[i])

  #Enterprise projects will usually return "Overview" for their descriptions. In that case, call the
  #enterprise_scrape function instead of the normal one.
  #if(new_data$Description == "Overview")
  #{
    #new_data <- enterprise_scrape(master_list_2[i])
  #}

  #New_SF<- rbind(New_SF, new_data)
  #Sys.sleep(runif(1, 0, 1) * 3)  ## randomly sleep the the system from 0 to 3 seconds
  #print(i)
  #save(new_data, file= sprintf('~/git/lab/oss/data/oss/original/sourceforge/new_data/SF_%06d.RData', i))
#}
#toc()
