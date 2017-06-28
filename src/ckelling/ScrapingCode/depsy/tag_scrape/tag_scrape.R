library(jsonlite)

maketagRow <- function(name){
  #name <- depsy_packages[1,1]
  #link <- "http://depsy.org/api/package/cran/A3"
  url <- paste('http://depsy.org/api/package/cran/', name, sep='')
  document <- jsonlite::fromJSON(txt=url)
  df <- c('name','tags')
  new_df <- c()

  oss_name <- document$name
  tags <- document$tags

  if(length(tags)>0){
    for(i in 1:length(document$tags)){
      tag_name <- tags[i]
      new_row <- c(oss_name, tag_name)
      new_df <- rbind(new_df, new_row)
      colnames(new_df) <- df
    }
  }
  return(new_df)
}


tag_mat <- c()
for(i in 1:nrow(depsy_packages)){
  #scrape details from API using rjson
  print(i)
  new_rows <- maketagRow(depsy_packages[i,1])
  tag_mat <- rbind(tag_mat, new_rows)
}


