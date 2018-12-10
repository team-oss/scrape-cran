library(rvest)
library(stringr)

rm(list = ls())

func = function(){
  # get the html doc and store it in var webpage
  webPage = read_html("https://bitnami.com/stacks")
  # store webpage as a RDS file; serves as reference only
  saveRDS(webPage, file = 'data/oss/original/Bitnami/raw_html_file.RDS')



  # parse app names
  name <- webPage %>% html_nodes(".stack__cards__card__info")
  #stacks > div:nth-child(2) > article > div.stack__cards__card__info > h5 > a
  name <- (name %>% html_text())
  name = str_extract_all(name, "(?<=\n\n)(.*?)(?=\n\n)")
  name = lapply(name, '[[', 1)
  name = unlist(name)

  # parse app categories
  category <- webPage %>% html_nodes(".stack__cards__card__footer")
  category <- (category %>% html_text())
  category <- sub("[\n]*", "", category)
  category = str_extract_all(category, "(?<=\n\n)(.*?)(?=\n\n)")
  category = unlist(category)



  #create dataframe
  df = data.frame("Name" = name, "Category" = category)
  outfile <- file.path("data/oss/working/Bitnami/parsed_info.csv")
  write.csv(df, outfile, row.names = FALSE)
}

func()
#####################################################
## loop through and search for repo
#searchUrl <- vector(mode = "character", length = length(name))
#name_url <- stringr::str_replace_all(name, ' ', '%20')
#searchUrl = str_c("https://www.google.com/search?q=", name_url, "%20GitHub")

#searchPage = GET(url = searchUrl[i]) %>%
  #content(as = 'text')
#grepl(pattern = 'a href="https://github.com/WordPress/WordPress"', x = searchPage)
#str_extract_all(string = searchPage, pattern = 'a href="https://github.com/WordPress/WordPress"')
#//*[@id="rso"]/div[1]/div/div/div/div/div/div/div/cite

#i = 1L
#searchPage = read_html(x = searchUrl[i]) %>%
  #html_nodes(css = "#rso > div:nth-child(1) > div > div > div > div > div > div > div > cite") %>% print

  #html_attr(name = 'href')
#searchPage

#rso > div:nth-child(1) > div > div > div > div > h3 > a

#for (i in 1:length(name_url)) {
  #search for repo on GitHub
  #searchPage = read_html(searchUrl[1])
  #candidateUrl <- searchPage %>% html_nodes(".fhJND5c.TbwUpd")
  #candidateUrl <- (name %>% html_text())
  #Sys.sleep(runif(1) * 10)
#}
#searchUrl = paste0("https://www.google.com/search?q=", name_url, "%20GitHub")
#searchPage = read_html(searchUrl[1])
#searchUrl
#name
#####################################################################


