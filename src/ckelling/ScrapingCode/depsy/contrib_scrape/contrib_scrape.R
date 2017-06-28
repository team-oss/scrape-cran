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

#source(file = "~/git/oss/src/ckelling/ScrapingCode/depsy/03_row_function.R")


makecontribRow <- function(name){
  #name <- depsy_packages[1,1]
  #link <- "http://depsy.org/api/package/cran/A3"
  url <- paste('http://depsy.org/api/package/cran/', name, sep='')
  document <- jsonlite::fromJSON(txt=url)
  df <- c('name','contrib')
  new_df <- c()

  oss_name <- document$name
  contribs <- document$all_contribs$name

  if(length(document$all_contribs$name) > 0){
    for(i in 1:length(document$all_contribs$name)){
      contrib_name <- contribs[i]
      new_row <- c(oss_name, contrib_name)
      new_df <- rbind(new_df, new_row)
      colnames(new_df) <- df
    }
  }
  return(new_df)
}


contrib_mat <- c()
for(i in 1:nrow(depsy_packages)){
  #scrape details from API using rjson
  print(i)
  new_rows <- makecontribRow(depsy_packages[i,1])
  contrib_mat <- rbind(contrib_mat, new_rows)
}

save(contrib_mat, file = "~/git/oss/data/oss/original/depsy/contrib_mat.Rdata")
