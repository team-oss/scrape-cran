#Now, I want to generate all contributors.
#library('RJSONIO')
#library("rjson")
library(jsonlite)

load(file = "~/git/oss/data/oss/original/depsy/error_vector.Rdata")
load(file= '~/git/oss/data/oss/original/depsy/all_packages_cran.Rdata')

#length(error_vec)/nrow(all_packages) #10.2% of the R packages on Cran are on Depsy
#nrow(all_packages)-length(error_vec) #there are 9,810 R packages on Depsy

#Creating list of all packages on Cran and Depsy
depsy_packages <- all_packages[-error_vec,] #these are the 9,810 R packages on Depsy and cran

source(file = "~/git/oss/src/ckelling/ScrapingCode/depsy/03_row_function.R")

neighb_mat <- c()
for(i in 1:nrow(depsy_packages)){
  #scrape details from API using rjson
  print(i)
  new_rows <- makeneighRow(depsy_packages[i,1])
  neighb_mat <- rbind(neighb_mat, new_rows)
}

save(neighb_mat, file = "~/git/oss/data/oss/original/depsy/neighb_mat.Rdata")
