library(rvest)
library(jsonlite)
library(httr)
library(stringr)

webPage = read_html("http://package.elm-lang.org/")

# parse app names
name <- webPage %>% html_nodes(".center")
name <- (name %>% html_text())
library(dplyr)
# keeps parentheses
str_extract_all(name, '\\(.*?\\)')
# w/out
a = str_extract_all(name, '(?<=\\().*?(?=\\))')
b=0
c = as.numeric(unlist(a))
for (i in 1 : length(c)){
b <- c[i] + b
}
# hard way
#gsub("[\\(\\)]", "", regmatches(name, gregexpr("\\(.*?\\)", name))[[1]])
CPAN = GET(url = 'https://fastapi.metacpan.org/v1/file/_search') %>%
  content(as = 'text', encoding = 'UTF-8') %>%
  fromJSON()






#SQL
#open connection:
#conn = con_db(dbname, pass)
#disconnect:
#on.exit(dbDisconnect(conn = conn))
