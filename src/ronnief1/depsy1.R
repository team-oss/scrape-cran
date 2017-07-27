#attempt to make a data table with each variable from depsy JSON files, Claire has a way better version of this
#this code is horribly inefficient, don't bother running it
library(rjson)
df <- c('citations_harv','citations_pmc', 'github_owner','github_repo_name','host', 'impact', 'impact_percentile', 'indegree', 'is_academic', 'language', 'name','neighborhood_size', 'num_authors', 'num_commits', 'num_committers', 'num_contribs', 'num_stars', 'num_downloads','perc_downloads',  'num_citations','perc_citations',  'num_deprank', 'perc_deprank', 'summary')
new_df <- as.data.frame(t(df), stringsAsFactors = FALSE)
colnames(new_df) <- df
new_df <- new_df[-1, ]
new_df
initializeLink <- function(link){
  url <- link
  doc <- fromJSON(txt=url)
  return(doc)
}
initializeLink("depsy.org/api/package/cran/httr")
df2 <- c('num_contribs', 'github_owner', 'github_repo_name', 'summary', 'num_authors', 'is_academic', 'language', 'indegree', 'name', 'impact', 'num_commits', 'num_committers', 'neighborhood_size', 'num_stars', 'impact_percentile', 'host')
makeRow <- function(df1, link){
  nextRow <- nrow(df1) + 1
  document <- initializeLink(link)
  df1[nextRow, 'num_contribs'] <- document$num_contribs
  if(is.null(document$github_owner)){
    df1[nextRow, 'github_owner'] <- 'null'
  }
  if(!(is.null(document$github_owner))){
    df1[nextRow, 'github_owner'] <- document$github_owner
  }
  df1[nextRow, 'summary'] <- document$summary
  if(is.null(document$github_repo_name)){
    df1[nextRow, 'github_repo_name'] <- 'null'
  }
  if(!(is.null(document$github_repo_name))){
    df1[nextRow, 'github_repo_name'] <- document$github_repo_name
  }
  df1[nextRow, 'num_authors'] <- document$num_authors
  df1[nextRow, 'is_academic'] <- document$is_academic
  df1[nextRow, 'language'] <- document$language
  df1[nextRow, 'indegree'] <- document$indegree
  df1[nextRow, 'name'] <- document$name
  df1[nextRow, 'impact'] <- document$impact

  if(is.null(document$num_commits)){
    df1[nextRow, 'num_commmits'] <- 'null'
  }
  if(!(is.null(document$num_commits))){
    df1[nextRow, 'num_commits'] <- document$num_commits
  }
  if(is.null(document$num_committers)){
    df1[nextRow, 'num_committers'] <- 'null'
  }
  if(!(is.null(document$num_committers))){
    df1[nextRow, 'num_committers'] <- document$num_committers
  }
  df1[nextRow, 'neighborhood_size'] <- document$neighborhood_size
  if(is.null(document$num_stars)){
    df1[nextRow, 'num_stars'] <- 'null'
  }
  if(!(is.null(document$num_stars))){
    df1[nextRow, 'num_stars'] <- document$num_stars
  }
  df1[nextRow, 'impact_percentile'] <- document$impact_percentile
  df1[nextRow, 'citations_harv'] <- document$citations_dict$count[1]
  df1[nextRow, 'citations_pmc'] <- document$citations_dict$count[2]
  df1[nextRow, 'host'] <- document$host
  df1[nextRow, 'num_downloads'] <- document$subscores[1,6]
  df1[nextRow, 'perc_downloads'] <- document$subscores[1, 5]
  df1[nextRow, 'num_citations'] <- document$subscores[2,6]
  df1[nextRow, 'perc_citations'] <- document$subscores[2, 5]
  df1[nextRow, 'num_deprank'] <- document$subscores[3,6]
  df1[nextRow, 'perc_deprank'] <- document$subscores[3, 5]
  return(df1)
}
new_df <- makeRow(new_df, "http://depsy.org/api/package/cran/ggplot2")
new_df <- makeRow(new_df, "http://depsy.org/api/package/cran/httr")
new_df <- makeRow(new_df, "http://depsy.org/api/package/cran/A3")

makeRow2 <- function(df100, link){
  nextRow <- nrow(df100) + 1
  document1 <- initializeLink(link)
  print(document1)
  print(class(document1))
  # loop though the variables i want
  for(i in 1:length(df2)){
    current_variable <- df2[i]
    print(sprintf('current variable: %s', current_variable))
    var_value <- document1[[current_variable]]
    print(var_value)

    if(is.null(var_value)){
      print('did not find something')
      df100[nextRow, toString(df2[i])] <- NULL
    } else {
      print('found something')
      print(var_value)
      print(nextRow)
      print(current_variable)
      print(df100[nextRow, current_variable])
      print(df100[3, 'github_owner'])
      df100[nextRow, current_variable] <- var_value
    }
    print('ending loop')
  }

  print('accessing table stuff')
  df100[nextRow, 'citations_harv'] <- document1$citations_dict$count[1]
  df100[nextRow, 'citations_pmc'] <- document1$citations_dict$count[2]
  df100[nextRow, 'num_downloads'] <- document1$subscores[1,6]
  df100[nextRow, 'perc_downloads'] <- document1$subscores[1, 5]
  df100[nextRow, 'num_citations'] <- document1$subscores[2,6]
  df100[nextRow, 'perc_citations'] <- document1$subscores[2, 5]
  df100[nextRow, 'num_deprank'] <- document1$subscores[3,6]
  df100[nextRow, 'perc_deprank'] <- document1$subscores[3, 5]
  return(df100)
}

new_df <- makeRow2(new_df, "http://depsy.org/api/package/cran/ggplot2")

new_df <- makeRow2(new_df, "http://depsy.org/api/package/cran/A3")

url <- "http://depsy.org/api/package/cran/httr"
doc <- fromJSON(txt=url)

