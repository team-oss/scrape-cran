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
  #name <- depsy_packages[2,1]
  #link <- "http://depsy.org/api/package/cran/A3"
  url <- paste('http://depsy.org/api/package/cran/', name, sep='')
  document <- jsonlite::fromJSON(txt=url)
  df <- c('oss_name','contrib','gitlogin', 'id', 'impact', 'impact_perc', 'is_org', 'main_lang', 'person_name', 'person_package_cred', 'roles', 'num_downloads','perc_downloads', 'num_deppagerank', 'perc_deppagerank', 'num_cit', 'perc_cit')
  new_df <- c()

  oss_name <- document$name
  contribs <- document$all_contribs$name

  if(length(document$all_contribs$name) > 0){
    for(i in 1:length(document$all_contribs$name)){
      #i=1
      contrib_name <- contribs[i]
      gitlogin <- document$all_contribs$github_login[i]
      id <- document$all_contribs$id[i]
      impact <- document$all_contribs$impact[i]
      impact_perc <- document$all_contribs$impact_percentile[i]
      is_org <- document$all_contribs$is_organization[i]
      main_lang <- document$all_contribs$main_language[i]
      person_name <- document$all_contribs$person_name[i]
      person_pack_cred <- document$all_contribs$person_package_credit[i]
      poss_roles <- colnames(document$all_contribs$roles)
      all_roles <- c()
      for(j in 1:length(poss_roles)){
        #j=2
        if(is.na(document$all_contribs$roles[i,j]) != TRUE){
          if(document$all_contribs$roles[i,j] != "FALSE"){
            #roles <- colnames(document$all_contribs$roles)[j]
            roles <- paste(colnames(document$all_contribs$roles)[j], "(",document$all_contribs$roles[i,j],")",sep="" )
            all_roles <- paste(all_roles, roles, sep=",")
          }
        }
      }
      all_roles <- substr(all_roles,2,nchar(all_roles))
      num_down <- document$all_contribs$subscores[[i]][1,5]
      perc_down <- document$all_contribs$subscores[[i]][1,4]
      num_dep_rank <- document$all_contribs$subscores[[i]][2,5]
      perc_dep_rank <- document$all_contribs$subscores[[i]][2,4]
      num_cit <- document$all_contribs$subscores[[i]][3,5]
      perc_cit <- document$all_contribs$subscores[[i]][3,4]


      df <- c('oss_name','contrib','gitlogin', 'id', 'impact', 'impact_perc', 'is_org', 'main_lang', 'person_name', 'person_package_cred', 'roles', 'num_downloads','perc_downloads', 'num_deppagerank', 'perc_deppagerank', 'num_cit', 'perc_cit')
      new_row <- c(oss_name, contrib_name, gitlogin, id, impact, impact_perc, is_org, main_lang, person_name, person_pack_cred, all_roles, num_down, perc_down, num_dep_rank, perc_dep_rank, num_cit, perc_cit)
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
