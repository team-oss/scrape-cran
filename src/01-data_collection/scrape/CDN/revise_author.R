library(data.table)
library(stringr)
library(dplyr)
library(purrr)

#############
my_db_con <- sdalr::con_db("oss", pass=sdalr::get_my_password())
authors <- DBI::dbReadTable(my_db_con, "CDN_authors_info")
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
##################################################################
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
fix_authors = function(authors) {
  #emails are not really "emails"; but since we use them as indicators, it is ok

  #manually fix a couple odd balls
  authors$name = trimws(authors$name)
  authors$author = trimws(authors$author)
  authors$email = trimws(authors$email)

  authors = mutate(authors, author = ifelse(test = (str_detect(author, "https") & str_detect(author, "contributors")),
                                        yes = "contributors",
                                        no = author))

  authors = mutate(authors, url = ifelse(test = (str_detect(author, "(?<=@)(.*?)(?=.com)")),
                                            yes = author,
                                            no = url))

  authors = mutate(authors, author = ifelse(test = (str_detect(author, "(?<=@)(.*?)(?=.com)")),
                                            yes = get_author(author),
                                            no = author))

  return(authors)
}
empty_as_na <- function(x){
  if("factor" %in% class(x)) x <- as.character(x) ## since ifelse wont work with factors
  ifelse(as.character(x)!="", x, NA)
}
##################################################################
owners = data.frame(name = general_info$name,
                    owner = str_extract_all(general_info$repository.url, "(?<=github.com.)(.*?)(?=/)", TRUE))
owners$name = trimws(owners$name)
owners$owner = trimws(owners$owner)
owners = owners %>% mutate_all(funs(empty_as_na))

#combined = lapply(general_info$name[1:10], fix_missing_author, owners[2])
#new_authors = do.call(what = rbind, args = combined)

temp = merge(authors, owners)
temp = mutate(temp, author = ifelse(test = is.na(x = author),
                                    yes = owner,
                                    no = author))
###########################################################
library(DBI)
library(sdalr)
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_authors_info",
             value = temp[,c('name', 'author', 'email')],
             row.names = FALSE,
             overwrite = TRUE)
