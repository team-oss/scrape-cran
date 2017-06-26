library(rvest)
library(rjson)
load(file= '~/git/oss/data/oss/original/depsy/all_packages_cran.Rdata')


#API for GGplot: http://depsy.org/api/package/cran/ggplot2
name_vec <- as.vector(all_packages$oss_name)

test <- c()
error_vec <- c()

error_message<- "Error in"
for(i in 1:length(name_vec)){
  link <- paste('http://depsy.org/api/package/cran/', name_vec[i], sep='')
  print(i)
  test <- try(read_html(link))
  error_test <- substr(test[1], 1, 8)
  if(error_test == error_message){
    error_vec <- rbind(error_vec, i)
  }
}

length(error_vec)
save(error_vec, file = "~/git/oss/data/oss/original/depsy/error_vector.Rdata")
