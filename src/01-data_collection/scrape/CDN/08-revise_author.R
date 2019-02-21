#parse author info in the second round

#libraries
library(data.table)
library(stringr)
library(dplyr)
library(purrr)
library(DBI)
library(sdalr)
source("functions_keren.R")
#############
#load df
my_db_con <- sdalr::con_db("oss", pass=sdalr::get_my_password())
authors <- DBI::dbReadTable(my_db_con, "CDN_authors_info")
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
##################################################################
#functions

#hardcoded: parse some known author names
#could be simplyfied but do note special character cases
#info is a string that could contain an author name;
#returns NA if no known name is detected
#return the infered author name
get_author = function(info) {
  if (str_detect(info, "dbrekalo")) {
    return("Damir Brekalo")
  } else if (str_detect(info, "igor.rafael")) {
    return("Igor Rafael")
  }else if (str_detect(info, "sayanee")) {
    return("Sayanee")
  }else if (str_detect(info, "eligrey")) {
    return("Eli Grey")
  }else if (str_detect(info, "danial.farid")) {
    return("Danial Farid")
  }else if (str_detect(info, "Mark DiMarco")) {
    return("Mark DiMarco")
  }else if (str_detect(info, "Paul Hodel")) {
    return("Paul Hodel")
  }else if (str_detect(info, "Jason Brown")) {
    return("Jason Brown")
  }else if (str_detect(info, "Bartłomiej Semańczyk kunass2")) {
    return("Bartłomiej Semańczyk kunass2")
  }else if (str_detect(info, "juicer.js authors")) {
    return("contributors")
  }else if (str_detect(info, "rocks.in.the.cloud")) {
    return("rocks.in.the.cloud")
  }else if (str_detect(info, "Matthew Blode")) {
    return("Matthew Blode")
  }else if (str_detect(info, "Alvaro Trigo")) {
    return("Alvaro Trigo")
  }else if (str_detect(info, "strozhevsky")) {
    return("Yury Strozhevsky")
  }else if (str_detect(info, "prettydiff")) {
    return("Austin Cheney")
  }else if (str_detect(info, "Travis Webb")) {
    return("Travis Webb")
  }else if (str_detect(info, "gajus")) {
    return("Gajus Kuizinas")
  }else if (str_detect(info, "Travis Webb")) {
    return("Matthew BlodeAlvaro Trigo")
  }else if (str_detect(info, "Travis Webb")) {
    return("Matthew BlodeAlvaro Trigo")
  }else if (str_detect(info, "alex.drom")) {
    return("Alex Drom")
  }else{
    return(NA)
  }
}

#parse author names
#authors is a df containing pkg names, author names, and author emails/urls
#return the df as parsed
fix_authors = function(authors) {

  #preparation
  authors$name = trimws(authors$name)
  authors$author = trimws(authors$author)
  authors$email = trimws(authors$email)

  #if a pkg's author entry is in the form of "http://...contributors", the author is defined as "contributors"
  authors = mutate(authors, author = ifelse(test = (str_detect(author, "https") & str_detect(author, "contributors")),
                                        yes = "contributors",
                                        no = author))

  #if a pkg's author entry is an email, the author is the extracted as the email's user name
  authors = mutate(authors, url = ifelse(test = (str_detect(author, "(?<=@)(.*?)(?=.com)")),
                                            yes = author,
                                            no = url))

  #same as above; handles oddballs
  authors = mutate(authors, author = ifelse(test = (str_detect(author, "(?<=@)(.*?)(?=.com)")),
                                            yes = get_author(author),
                                            no = author))

  return(authors)
}

#replace all empty entries in a set as NAs
#x is a arbitary set
empty_as_na <- function(x){
  if("factor" %in% class(x)) x <- as.character(x) ## since ifelse wont work with factors
  ifelse(as.character(x)!="", x, NA)
}
##################################################################
#script

#parse authors
authors <- lapply(X = authors, FUN = fix_authors)

#extract and parse repo owners
owners = data.frame(name = general_info$name,
                    owner = str_extract_all(general_info$repository.url, "(?<=github.com.)(.*?)(?=/)", TRUE))
owners$name = trimws(owners$name)
owners$owner = trimws(owners$owner)
owners = owners %>% mutate_all(funs(empty_as_na))

#merge pkg authors and repo owners; if an author is missing, the owner is considered author
temp = merge(authors, owners)
temp = mutate(temp, author = ifelse(test = is.na(x = author),
                                    yes = owner,
                                    no = author))
###########################################################
#upload result

my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_authors_info",
             value = temp[,c('name', 'author', 'email')],
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))