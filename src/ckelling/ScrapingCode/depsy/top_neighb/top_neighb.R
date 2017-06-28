#Now, I want to generate top contributors.
#library('RJSONIO')
#library("rjson")
library(jsonlite)

load(file = "~/git/oss/data/oss/original/depsy/error_vector.Rdata")
load(file= '~/git/oss/data/oss/original/depsy/all_packages_cran.Rdata')

#Creating list of all packages on Cran and Depsy
depsy_packages <- all_packages[-error_vec,] #these are the 9,810 R packages on Depsy and cran

#source(file = "~/git/oss/src/ckelling/ScrapingCode/depsy/03_row_function.R")

maketopneighbRow <- function(name){
  name <- depsy_packages[1,1]
  #link <- "http://depsy.org/api/package/cran/A3"
  url <- paste('http://depsy.org/api/package/cran/', name, sep='')
  document <- jsonlite::fromJSON(txt=url)
  df <- c('oss_name','top_neighb')
  new_df <- c()

  oss_name <- document$name
  topneighbs <- document$top_neighbors

  if(length(document$top_neighbs) > 0){
    for(i in 1:length(top_neighbs)){
      topneighb <- topneighbs[i]
      new_row <- c(oss_name, topneighb)
      new_df <- rbind(new_df, new_row)
      colnames(new_df) <- df
    }
  }
  return(new_df)
}


topneighb_mat <- c()
for(i in 1:nrow(depsy_packages)){
  #scrape details from API using rjson
  print(i)
  new_rows <- maketopneighbRow(depsy_packages[i,1])
  topneighb_mat <- rbind(topneighb_mat, new_rows)
}

save(topneighb_mat, file = "~/git/oss/data/oss/original/depsy/topneighb_mat.Rdata")
