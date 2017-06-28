library('RJSONIO')
library("rjson")
library(jsonlite)

load(file = "~/git/oss/data/oss/original/depsy/error_vector.Rdata")
load(file= '~/git/oss/data/oss/original/depsy/all_packages_cran.Rdata')

length(error_vec)/nrow(all_packages) #10.2% of the R packages on Cran are on Depsy
nrow(all_packages)-length(error_vec) #there are 9,810 R packages on Depsy

#Creating list of all packages on Cran and Depsy
depsy_packages <- all_packages[-error_vec,] #these are the 9,810 R packages on Depsy and cran

# raw_data<-fromJSON("http://depsy.org/api/package/cran/A3")
# node_data <- matrix(nrow=9810,ncol=18)
# col_names(node_data) <- c("")
#
# node_data$name <- c('citations_harv','citations_pmc', 'git_owner','git_repo_name','host', 'impact', 'impact_percentile', 'indegree', 'is_academic', 'language', 'name','neighborhood_size', 'num_authors', 'num_commits', 'num_committers', 'num_contribs', 'num_stars', 'downloads', 'citations', 'dep_rank', 'summary')
#
# perc_downloads <- raw_data[[19]][[1]][[5]]
# num_downloads <- raw_data[[19]][[1]][[6]]
# perc_cit <- raw_data[[19]][[2]][[5]]
# num_cit <- raw_data[[19]][[2]][[6]]
# perc_deprank <- raw_data[[19]][[3]][[5]]
# num_deprank <- raw_data[[19]][[3]][[6]]
# summary <- raw_data[[20]]
#
# raw_data<-fromJSON("http://depsy.org/api/package/cran/abctools")
# neighbors <- raw_data[[2]]


source(file = "~/git/oss/src/ckelling/ScrapingCode/depsy/03_row_function.R")
node_mat <- c()
#for(i in 1:length(depsy_packages)){

for(i in 1:nrow(depsy_packages)){
  #scrape details from API using rjson
  print(i)
  new_row <- makeRow(depsy_packages[i,1])
  node_mat <- rbind(node_mat, new_row)
}

# edge_list <- c()
# for(i in 1:length(depsy_packages)){
#   #form edge list of all neighbor_id's that start with cran:
#
# }

save(node_mat, file = "~/git/oss/data/oss/original/depsy/node_mat.Rdata")
#save(edge_list, file = "~/git/oss/data/oss/original/depsy/edge_list.Rdata")
