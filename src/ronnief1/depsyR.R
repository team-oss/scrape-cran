#Depsy python to R code
#Variables:
# names = [name]
# dependency_rank = []
# impact_score = []
# number_reused_by = []
# number_contributors = []
# number_downloads = []
# number_citations = []
# hood_size = []
# number_commits = []
# is_academic = []
# contrib_rank = []
# all_tags = []







#get variables from each page
#neighbors that start with "cran:"

# json_file <- "http://depsy.org/api/package/cran/httr"
# json_data <- fromJSON(file=json_file)
# json_data
document$all_contribs
neighbor_ids <- document$all_neighbor_ids
neighbor_ids
class(neighbor_ids)
cran_neighbors <- c()
j <- 0
for(i in 1:length(neighbor_ids)){
  if(substr(neighbor_ids[i],0,5) == "cran:"){
    cran_neighbors[j] <- neighbor_ids[i]
    j <- j + 1
  }
}
cran_neighbors
cran_urls <- c()
substr(cran_neighbors[5], 6, length(cran_neighbors))
for(i in 1:length(cran_neighbors)){
  cran_urls[i] <- substr(cran_neighbors[i], 6, length(cran_neighbors))
}
cran_urls
length(cran_neighbors)

for(i in 1:length(cran_urls)){
  cran_url[i] <- paste("http://depsy.org/api/package/cran/", cran_urls[i], sep="")
}
cran_url
##############################################################################################################################################
library("rjson")
library("jsonlite")
url <- "http://depsy.org/api/package/cran/httr"
document <- fromJSON(txt=url)
document
df <- c('citations_harv','citations_pmc', 'git_owner','git_repo_name','host', 'impact', 'impact_percentile', 'indegree', 'is_academic', 'language', 'name','neighborhood_size', 'num_authors', 'num_commits', 'num_committers', 'num_contribs', 'num_stars', 'num_downloads','perc_downloads',  'num_citations','perc_citations',  'num_deprank', 'perc_deprank', 'summary')
makeRow <- function(link){
  url <- link
  document <- fromJSON(txt=url)
  df <- c('citations_harv','citations_pmc', 'git_owner','git_repo_name','host', 'impact', 'impact_percentile', 'indegree', 'is_academic', 'language', 'name','neighborhood_size', 'num_authors', 'num_commits', 'num_committers', 'num_contribs', 'num_stars', 'num_downloads','perc_downloads',  'num_citations','perc_citations',  'num_deprank', 'perc_deprank', 'summary')
  contribs <- ac$github_login
  contribs
  new_df <- as.data.frame(t(df), stringsAsFactors = FALSE)
  colnames(new_df) <- df
  new_df <- new_df[-1, ]
  new_df[1, 'num_contribs'] <- length(contribs)
  new_df[1, 'git_owner'] <- document$github_owner
  new_df[1, 'summary'] <- document$summary
  new_df[1, 'git_repo_name'] <- document$github_repo_name
  new_df[1, 'num_authors'] <- document$num_authors
  new_df[1, 'is_academic'] <- document$is_academic
  new_df[1, 'language'] <- document$language
  #new_df[1, 'citations_dict'] <- document$citations_dict
  new_df[1, 'indegree'] <- document$indegree
  new_df[1, 'name'] <- document$name
  new_df[1, 'impact'] <- document$impact
  new_df[1, 'num_commits'] <- document$num_commits
  new_df[1, 'num_committers'] <- document$num_committers
  new_df[1, 'neighborhood_size'] <- document$neighborhood_size
  new_df[1, 'num_stars'] <- document$num_stars
  new_df[1, 'impact_percentile'] <- document$impact_percentile
  new_df[1, 'citations_harv'] <- document$citations_dict$count[1]
  new_df[1, 'citations_pmc'] <- document$citations_dict$count[2]
  new_df[1, 'host'] <- document$host
  new_df[1, 'num_downloads'] <- document$subscores[1,6]
  new_df[1, 'perc_downloads'] <- document$subscores[1, 5]
  new_df[1, 'num_citations'] <- document$subscores[2,6]
  new_df[1, 'perc_citations'] <- document$subscores[2, 5]
  new_df[1, 'num_deprank'] <- document$subscores[3,6]
  new_df[1, 'perc_deprank'] <- document$subscores[3, 5]
  return(new_df)
}


contribs <- ac$github_login
contribs
new_df <- as.data.frame(t(df), stringsAsFactors = FALSE)
colnames(new_df) <- df
new_df <- new_df[-1, ]
new_df[1, 'num_contribs'] <- length(contribs)
new_df[1, 'git_owner'] <- document$github_owner
new_df[1, 'summary'] <- document$summary
new_df[1, 'git_repo_name'] <- document$github_repo_name
new_df[1, 'num_authors'] <- document$num_authors
new_df[1, 'is_academic'] <- document$is_academic
new_df[1, 'language'] <- document$language
#new_df[1, 'citations_dict'] <- document$citations_dict
new_df[1, 'indegree'] <- document$indegree
new_df[1, 'name'] <- document$name
new_df[1, 'impact'] <- document$impact
new_df[1, 'num_commits'] <- document$num_commits
new_df[1, 'num_committers'] <- document$num_committers
new_df[1, 'neighborhood_size'] <- document$neighborhood_size
new_df[1, 'num_stars'] <- document$num_stars
new_df[1, 'impact_percentile'] <- document$impact_percentile
new_df[1, 'citations_harv'] <- document$citations_dict$count[1]
new_df[1, 'citations_pmc'] <- document$citations_dict$count[2]
new_df[1, 'host'] <- document$host
new_df[1, 'num_downloads'] <- document$subscores[1,6]
new_df[1, 'perc_downloads'] <- document$subscores[1, 5]
new_df[1, 'num_citations'] <- document$subscores[2,6]
new_df[1, 'perc_citations'] <- document$subscores[2, 5]
new_df[1, 'num_deprank'] <- document$subscores[3,6]
new_df[1, 'perc_deprank'] <- document$subscores[3, 5]
######################################################################################################################
######################################################################################################################
makeRow <- function(link){
  url <- link
  document <- fromJSON(txt=url)
  df <- c('citations_harv','citations_pmc', 'git_owner','git_repo_name','host', 'impact', 'impact_percentile', 'indegree', 'is_academic', 'language', 'name','neighborhood_size', 'num_authors', 'num_commits', 'num_committers', 'num_contribs', 'num_stars', 'num_downloads','perc_downloads',  'num_citations','perc_citations',  'num_deprank', 'perc_deprank', 'summary')
  contribs <- ac$github_login
  contribs
  new_df <- as.data.frame(t(df), stringsAsFactors = FALSE)
  colnames(new_df) <- df
  new_df <- new_df[-1, ]
  new_df[1, 'num_contribs'] <- length(contribs)
  new_df[1, 'git_owner'] <- document$github_owner
  new_df[1, 'summary'] <- document$summary
  new_df[1, 'git_repo_name'] <- document$github_repo_name
  new_df[1, 'num_authors'] <- document$num_authors
  new_df[1, 'is_academic'] <- document$is_academic
  new_df[1, 'language'] <- document$language
  #new_df[1, 'citations_dict'] <- document$citations_dict
  new_df[1, 'indegree'] <- document$indegree
  new_df[1, 'name'] <- document$name
  new_df[1, 'impact'] <- document$impact
  new_df[1, 'num_commits'] <- document$num_commits
  new_df[1, 'num_committers'] <- document$num_committers
  new_df[1, 'neighborhood_size'] <- document$neighborhood_size
  new_df[1, 'num_stars'] <- document$num_stars
  new_df[1, 'impact_percentile'] <- document$impact_percentile
  new_df[1, 'citations_harv'] <- document$citations_dict$count[1]
  new_df[1, 'citations_pmc'] <- document$citations_dict$count[2]
  new_df[1, 'host'] <- document$host
  new_df[1, 'num_downloads'] <- document$subscores[1,6]
  new_df[1, 'perc_downloads'] <- document$subscores[1, 5]
  new_df[1, 'num_citations'] <- document$subscores[2,6]
  new_df[1, 'perc_citations'] <- document$subscores[2, 5]
  new_df[1, 'num_deprank'] <- document$subscores[3,6]
  new_df[1, 'perc_deprank'] <- document$subscores[3, 5]
  return(new_df)
}
df2 <- makeRow("http://depsy.org/api/package/cran/httr")
