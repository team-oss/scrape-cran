#this is a cleaning script to produce a list of OSI CI approved github slugs with package names
library(stringr)
library(dplyr)
library(data.table)
library(sdalr)
library(DBI)
library(data.table)

cran <- readRDS('./data/oss/working/CRAN_2018/OSI_CI_PASS.RDS')

#now apply same cleaning steps as in 05_counting.R but save the package name
urls <- cran[!is.na(cran$'URL:'),]
colnames(urls)[17] <- 'URL'
urls$URL <- as.character(urls$URL)

urls$slug <- seq(1:nrow(urls))
urls$slug <- as.character(urls$slug)
safety_net <- urls$'BugReports:' #taking bug reports link if it is a github.io link

urls <- data.table(cbind(urls$name,urls$URL,safety_net))
colnames(urls)[1] <- 'name'
colnames(urls)[2] <- 'URL'
#this is how we extract any packags with GITHUB in it
# urls$slug <- str_extract(urls$URL, "(\\S+(?=\\github.com)\\S+)")
# urls$slug <- str_replace_all(urls$slug,",","")
#replace .io with real slug, take out anything not a github link
for(i in 1:nrow(urls)){
  name <- str_extract(urls$URL[i], "(\\S+(?=\\github.com)\\S+)")
  name <- str_replace(name,",","")
  help <- urls$safety_net[i]
  if(is.na(name)||str_detect(name, '\\.io$') || !str_detect(name,"\\//github.com")){
    name <- help
  }
  #replace slug with the issues link, if available
  name <- str_remove(name,"/$")
  name <- str_remove(name,"\\/issues")
  urls$slug[i] <- name
}
# urls$URL <- str_replace_all(urls$URL,",.*","")
# urls$URL <- str_replace_all(urls$URL,"\\s.*","")

#filter github urls, declare it a character
urls <- urls[str_detect(urls$slug,'github'),]

#get slug vector
slugs <- urls$slug
#omit na, and then get the parsed slug
slugs <- str_replace_all(slugs,".*github.com/","")
slugs <- str_replace_all(slugs, "/$","")
slugs <- str_replace_all(slugs, "\\.git$","")
slugs <- str_extract(slugs, ".+?\\/([a-zA-Z0-9.\\-\\_,!@$%^&*()]+)")

length(slugs)
length(unique(slugs))

#add back into main data
urls$slug <- slugs

finals <- urls[!is.na(urls$slug)]
colnames(finals)[3] <- "bug_report"

#save
saveRDS(finals, file = './data/oss/working/CRAN_2018/name_slug_keys.RDS')
#write to db

#Bayoan needs the package name and slug keys
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS')
keys <- data.table(keys)
#write to database
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CRAN_name_slug_keys",
             value = finals,
             row.names = FALSE,
             overwrite = TRUE)
